defmodule Minesweeper do
  def is_mine(board, row, column), do: Minesweeper.Utils.get_from_matrix(board, row, column)

  def is_valid_position(_board_size, row, column) when row < 0 or column < 0, do: false
  def is_valid_position(board_size, row, column), do: row < board_size and column < board_size

  def is_game_over(mines_board, player_board), do: count_mines(mines_board) == count_closed_positions(player_board)

  def generate_empty_mines_board(size), do: Minesweeper.Utils.create_matrix(size, size, false)

  def add_mines_to_board(mines_board, 0, _size) do
    mines_board
  end
  def add_mines_to_board(mines_board, n, size) do
    row = :rand.uniform(size - 1)
    column = :rand.uniform(size - 1)

    if is_mine(mines_board, row, column) do
      add_mines_to_board(mines_board, n, size)
    else
      mines_board = Minesweeper.Utils.update_matrix(mines_board, row, column, true)
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

  def open_move([], _player_board, _row, _column), do: raise "Empty mines board!"
  def open_move(_mines_board, [], _row, _column), do: raise "Empty player board!"
  def open_move(_mines_board, player_board, row, column) when row < 0 and column < 0, do: player_board
  def open_move(mines_board, player_board, row, column) do
    if is_mine(mines_board, row, column) == true || Minesweeper.Utils.get_from_matrix(player_board, row, column) != closed_position() do
      player_board
    else
      num_adjacent_mines = count_adjacent_mines(mines_board, row, column)
      player_board = Minesweeper.Utils.update_matrix(player_board, row, column, num_adjacent_mines)

      case num_adjacent_mines do
        0 -> get_adjacent_positions(length(mines_board), row, column)
              |> Enum.reduce(player_board, fn({r, c}, new_player_board) -> open_move(mines_board, new_player_board, r, c) end)
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

  defp open_lines(mines_board, player_board, 0, column), do: open_position(mines_board, player_board, 0, column)
  defp open_lines(mines_board, player_board, row, column) do
    player_board = open_position(mines_board, player_board, row, column)
    open_lines(mines_board, player_board, row - 1, column)
  end

  defp open_columns(mines_board, player_board, row, 0), do: open_lines(mines_board, player_board, row, 0)
  defp open_columns(mines_board, player_board, row, column) do
    player_board = open_lines(mines_board, player_board, row, column)
    open_columns(mines_board, player_board, row, column - 1)
  end

  def open_board(mines_board, player_board) do
    open_columns(mines_board, player_board, length(player_board) - 1, length(player_board) - 1)
  end

  def get_horizontal_header(num_columns) do
    "A B C D E F G H I J K L M N O P Q R S T U V W X Y Z AA AB AC AD AE AF AG AH AI AJ AK AL"
    |> String.split(" ")
    |> Enum.slice(0, num_columns)
  end

  def get_horizontal_split(num_columns) do
    "_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _"
    |> String.split(" ")
    |> Enum.slice(0, num_columns)
  end

  def player_board_to_string(player_board) do
    player_board2 = player_board
    |> Enum.with_index()
    |> Enum.map(fn({line, index}) -> line ++ ["| #{index + 1}"] end)

    [get_horizontal_header(length(player_board))] ++ [get_horizontal_split(length(player_board))] ++ player_board2
    |> Enum.map(fn(x) -> Enum.join(x, " ") end)
    |> Enum.join("\n")
  end

  def letter_to_index(letter) do
    [left, _] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    |> String.split(letter, parts: 2)
    String.length(left)
  end

  def number_to_index(num), do: num - 1

  def mine(), do: "*"
  def flag(), do: ">"
  def closed_position(), do: "-"
  def opened_position(n), do: n
end

defmodule Minesweeper.CLI do
  def main(_args \\ []) do
    {size, _} = IO.gets("Board size: ") |> String.trim("\n") |> Integer.parse
    {num_mines, _} = IO.gets("Number of mines: ") |> String.trim("\n") |> Integer.parse

    mines_board = Minesweeper.generate_empty_mines_board(size) |> Minesweeper.add_mines_to_board(num_mines, size)
    player_board = Minesweeper.generate_player_board(size)

    t_start = DateTime.utc_now()
    game_loop(mines_board, player_board, t_start)
    t_game = DateTime.diff(DateTime.utc_now(), t_start)

    minu = Integer.floor_div(t_game, 60)
    sec = rem(t_game, 60)
    IO.puts("Total time: #{minu}:#{sec}")
  end

  defp get_position() do
    [column, row] = IO.gets("Position (ex.: A 2): ") |> String.trim("\n") |> String.split(" ")
    column = column |> String.upcase() |> Minesweeper.letter_to_index()
    {row, _} = row |> Integer.parse()
    row = Minesweeper.number_to_index(row)
    {row, column}
  end

  defp game_loop(mines_board, player_board, t_start) do
    IO.puts("")
    IO.puts(Minesweeper.player_board_to_string(player_board))
    IO.puts("")

    t_game = DateTime.diff(DateTime.utc_now(), t_start)
    minu = Integer.floor_div(t_game, 60)
    sec = rem(t_game, 60)
    IO.puts("Timer: #{minu}:#{sec}")

    command = IO.gets("Enter a command (open, flag, unflag, exit): ") |> String.trim("\n")

    case command do
      "exit" ->
        IO.puts("")

        IO.puts(Minesweeper.player_board_to_string(Minesweeper.open_board(mines_board, player_board)))

        IO.puts("Exiting...")
      "flag" ->
        {row, column} = get_position()

        player_board = Minesweeper.flag_position(player_board, row, column)

        game_loop(mines_board, player_board, t_start)
      "unflag" ->
        {row, column} = get_position()

        player_board = Minesweeper.unflag_position(player_board, row, column)

        game_loop(mines_board, player_board, t_start)
      "open" ->
        {row, column} = get_position()

        player_board = Minesweeper.open_move(mines_board, player_board, row, column)

        if Minesweeper.is_mine(mines_board, row, column) do
          IO.puts("Game over!")

          IO.puts(Minesweeper.player_board_to_string(Minesweeper.open_board(player_board)))
        else
          game_loop(mines_board, player_board, t_start)
        end
      _ ->
        IO.puts("Unknown command!")
        game_loop(mines_board, player_board, t_start)
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
  def get_from_array(_list, pos) when pos < 0, do: raise "Index out of bounds!"
  def get_from_array([h|_t], 0), do: h
  def get_from_array([h|t], pos) when pos < 0, do: get_from_array([h|t], length([h|t]) + pos)
  def get_from_array([_h|t], pos), do: get_from_array(t, pos - 1)

  def update_array([], _pos, _value), do: raise "Index out of bounds!"
  def update_array(_list, pos, _value) when pos < 0, do: raise "Index out of bounds!"
  def update_array([_h|t], 0, value), do: [value|t]
  def update_array([h|t], pos, value), do: [h|update_array(t, pos - 1, value)]

  def create_matrix(1, n_columns, value), do: [create_array(n_columns, value)]
  def create_matrix(n_rows, n_columns, value) do
    [create_array(n_columns, value)] ++ create_matrix(n_rows - 1, n_columns, value)
  end

  def get_from_matrix(_matrix, row, column) when row < 0 and column < 0, do: raise "Index out of bounds!"
  def get_from_matrix(matrix, row, column), do: get_from_array(get_from_array(matrix, row), column)

  def update_matrix([], _row, _column, _value), do: []
  def update_matrix(_list, row, column, _value) when row < 0 and column < 0, do: raise "Index out of bounds!"
  def update_matrix([h|t], 0, column, value), do: [update_array(h, column, value) | t]
  def update_matrix([h|t], row, column, value), do: [h | update_matrix(t, row - 1, column, value)]
end
