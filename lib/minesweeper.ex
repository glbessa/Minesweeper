defmodule Minesweeper do
  def is_mine(board, row, column), do: Minesweeper.Utils.get_from_matrix(board, row, column)

  def is_valid_position(_board_size, row, column) when row < 0 and column < 0, do: false
  def is_valid_position(board_size, row, column), do: row < board_size and column < board_size

  def is_game_over(mines_board, player_board), do: count_mines(mines_board) == count_closed_positions(player_board)

  def generate_empty_mines_board(size), do: Minesweeper.Utils.create_matrix(size, size, false)

  def add_mines_to_board(mines_board, 0, _size), do: mines_board
  def add_mines_to_board(mines_board, n, size) do
    row = :rand.uniform(size - 1)
    column = :rand.uniform(size - 1)

    if is_mine(mines_board, row, column) do
      add_mines_to_board(mines_board, n, size)
    else
      add_mines_to_board(mines_board, n - 1, size)
    end
  end

  def generate_player_board(size), do: Minesweeper.Utils.create_matrix(size, size, closed_position())

  def get_adjacent_positions(board_size, row, column) do
    adjacent = [
      {row-1, column-1},
      {row-1, column},
      {row-1, column+1},
      {row, column-1},
      {row, column+1},
      {row+1, column-1},
      {row+1, column},
      {row+1, column+1}
    ]

    Enum.filter(adjacent, fn({r, c}) -> is_valid_position(board_size, r, c) end)
  end

  def count_adjacent_mines(mines_board, row, column) do
    length(mines_board)
    |> get_adjacent_positions(row, column)
    |> Enum.map(fn({r, c}) -> Minesweeper.Utils.get_from_matrix(mines_board, r, c) end)
    |> Enum.filter(fn(x) -> x == true end)
    |> Enum.map(fn(_x) -> 1 end)
    |> Enum.reduce(0, fn(x, y) -> x + y end)
  end

  def count_mines(mines_board) do
    mines_board
    |> Enum.map(fn(x) -> Enum.filter(x, fn(y) -> y end) end) # filter mines for each row
    |> Enum.filter(fn(x) -> x != [] end) # filter rows without mines
    |> Enum.map(fn(x) -> Enum.map(x, fn(_y) -> 1 end) end) # attribute 1 to each mine
    |> Enum.map(fn(x) -> Enum.reduce(x, fn(y1, y2) -> y1 + y2 end) end) # count number of mines in each row
    |> Enum.reduce(fn(x, y) -> x + y end) # count total number of mines
  end

  def count_closed_positions(player_board) do
    player_board
    |> Enum.map(fn(x) -> Enum.filter(x, fn(y) -> y == closed_position() end) end)
    |> Enum.filter(fn(x) -> x != [] end)
    |> Enum.map(fn(x) -> Enum.map(x, fn(_y) -> 1 end) end)
    |> Enum.map(fn(x) -> Enum.reduce(x, fn(y1, y2) -> y1 + y2 end) end)
    |> Enum.reduce(fn(x, y) -> x + y end)
  end

  def flag_position(player_board, row, column) do
    if Minesweeper.Utils.get_from_matrix(player_board, row, column) == closed_position() do
      Minesweeper.Utils.update_matrix(player_board, row, column, flag())
    else
      player_board
    end
  end
  def unflag_position(player_board, row, column) do
    if Minesweeper.Utils.get_from_matrix(player_board, row, column) == flag() do
      Minesweeper.Utils.update_matrix(player_board, row, column, closed_position())
    else
      player_board
    end
  end

  def open_move(mines_board, player_board, row, column) do
    if is_mine(mines_board, row, column) == true || Minesweeper.Utils.get_from_matrix(player_board, row, column) != closed_position() do
      player_board
    else
      num_adjacent_mines = count_adjacent_mines(mines_board, row, column)
      player_board = Minesweeper.Utils.update_matrix(player_board, row, column, num_adjacent_mines)

      case num_adjacent_mines do
        0 -> get_adjacent_positions(length(mines_board), row, column) |> Enum.reduce(player_board, fn({r, c}, new_player_board) -> open_move(mines_board, new_player_board, r, c) end)
        _ -> player_board
      end
    end
  end

  def open_position(mines_board, player_board, row, column) do
    if is_mine(mines_board, row, column) do
      Minesweeper.Utils.update_matrix(player_board, row, column, mine())
    else
      if Minesweeper.Utils.get_from_matrix(player_board, row, column) == closed_position() || Minesweeper.Utils.get_from_matrix(player_board, row, column) == flag() do
        Minesweeper.Utils.update_matrix(player_board, row, column, count_adjacent_mines(mines_board, row, column))
      else
        player_board
      end
    end
  end

  def player_board_to_string(player_board) do
    IO.inspect(player_board)
  end

  def mine(), do: "*"
  def flag(), do: ">"
  def closed_position(), do: "-"
  def opened_position(n), do: n
end

defmodule Minesweeper.CLI do
  def main(_args \\ []) do
    size = 10
    num_mines = 3
    mines_board = Minesweeper.generate_empty_mines_board(size) |> Minesweeper.add_mines_to_board(num_mines, size)
    player_board = Minesweeper.generate_player_board(size)

    game_loop(mines_board, player_board)
  end

  defp game_loop(mines_board, player_board) do
    IO.puts(Minesweeper.player_board_to_string(player_board))
    command = IO.gets("Enter a command: ") |> String.trim("\n")

    case command do
      "exit" ->
        IO.puts("Saindo...")
      "flag" ->
        {row, _remainder} = IO.gets("Line: ") |> Integer.parse
        {column, _remainder} = IO.gets("Column: ") |> Integer.parse
        player_board = Minesweeper.flag_position(player_board, row, column)
        game_loop(mines_board, player_board)
      "unflag" ->
        {row, _remainder} = IO.gets("Line: ") |> Integer.parse
        {column, _remainder} = IO.gets("Column: ") |> Integer.parse
        player_board = Minesweeper.unflag_position(player_board, row, column)
        game_loop(mines_board, player_board)
      "open" ->
        {row, _remainder} = IO.gets("Line: ") |> Integer.parse
        {column, _remainder} = IO.gets("Column: ") |> Integer.parse
        player_board = Minesweeper.open_move(mines_board, player_board, row, column)
        if Minesweeper.is_mine(mines_board, row, column) do
          IO.puts("Perdeu mané! Mas foi quase...")
          IO.puts(Minesweeper.player_board_to_string(player_board))
        else
          game_loop(mines_board, player_board)
        end
    end
  end
end


defmodule Minesweeper.Utils do
  # Matrix manipulation
  def create_array(0, _value), do: []
  def create_array(n, value) do
    [value] ++ create_array(n - 1, value)
  end

  def get_from_array([], _pos), do: raise "Index out of bounds!"
  def get_from_array([h|_t], 0), do: h
  def get_from_array([h|t], pos) when pos < 0, do: get_from_array([h|t], length([h|t]) + pos)
  def get_from_array([_h|t], pos), do: get_from_array(t, pos - 1)

  def update_array([], _pos, _value), do: raise "Index out of bounds!"
  def update_array([_h|t], 0, value), do: [value|t]
  def update_array([h|t], pos, value), do: [h|update_array(t, pos - 1, value)]

  def create_matrix(1, n_columns, value), do: [create_array(n_columns, value)]
  def create_matrix(n_rows, n_columns, value) do
    [create_array(n_columns, value)] ++ create_matrix(n_rows - 1, n_columns, value)
  end

  def get_from_matrix(matrix, row, column), do: get_from_array(get_from_array(matrix, row), column)

  def update_matrix([h|t], 0, column, value), do: [update_array(h, column, value) | t]
  def update_matrix([h|t], row, column, value), do: [h | update_matrix(t, row - 1, column, value)]
end

Minesweeper.CLI.main()
