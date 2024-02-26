defmodule Minesweeper.Utils do
  @moduledoc """

  """

  @doc """
    get_from_array(list, position)

    Get an item from an array at position.
  """
  def get_from_array([], _pos), do: raise "Index out of bounds!"
  def get_from_array([h|_t], 0), do: h
  def get_from_array([h|t], pos) when pos < 0,  do: get_from_array([h|t], length([h|t]) + pos)
  def get_from_array([_h|t], pos), do: get_from_array(t, pos - 1)

  @doc """
    update_array(list, position, value)


  """
  def update_array([], _pos, _value), do: raise "Index out of bounds!"
  def update_array([_h|t], 0, value), do: [value|t]
  def update_array([h|t], pos, value), do: [h|update_array(t, pos - 1, value)]

  @doc """
    get_from_matrix(matrix, row, column)

  """
  def get_from_matrix(matrix, row, column), do: get_from_array(get_from_array(matrix, row), column)

  @doc """
    update_matrix(matrix, row, column, value)

  """
  def update_matrix([h|t], 0, column, value), do: [update_array(h, column, value) | t]
  def update_matrix([h|t], row, column, value), do: [h | update_matrix(t, row - 1, column, value)]

  @doc """
    is_mine(board, row, column)

  """
  def is_mine(board, row, column), do: get_from_matrix(board, row, column)

  @doc """
    def is_valid_position(board_length, row, column)

  """
  def is_valid_position(_board_length, row, column) when row < 0 && column < 0, do: false
  def is_valid_position(board_length, row, column) do
    row < board_length && column < board_length
  end

  @doc """
    def adjacent_positions(board_length, row, column)

  """
  def adjacent_positions(board_length, row, column) do
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

    Enum.filter(adjacent, fn({r, c}) -> is_valid_position(board_length, r, c) end)
  end

  @doc """
    def count_adjacent_mines(mines_board, row, column)

    returns
  """
  def count_adjacent_mines(mines_board, row, column) do
    length(mines_board)
    |> adjacent_position(row, column)
    |> Enum.map(fn({r, c}) -> get_from_matrix(board, r, c) end)
    |> Enum.filter(fn(x) -> x end)
    |> Enum.map(fn(x) -> 1 end)
    |> Enum.reduce(fn(x, y) -> x + y end)
  end

  @doc """
    def flag_position(flags_board, row, column)

  """
  def flag_position(flags_board, row, column), do: update_matrix(flags_board, row, column, true)

  @doc """
    def unflag_position(flags_board, row, column)

  """
  def unflag_position(flags_board, row, column), do: update_matrix(flags_board, row, column, false)


  @doc """

  """
  def open_move(mines_board, player_board, row, column) do

  end

  @doc """
    def open_position(mines_board, player_board, row, column)

    returns

    {updated player's board , has lost}

  """
  def open_position(mines_board, player_board, row, column) when is_mine(mines_board, row, column) == true do
    {update_matrix(player_board, row, column, :mine), true}
  end
  def open_position(mines_board, player_board, row, column) when is_mine(mines_board, row, column) == false do
    num_adjancent_mines = count_adjacent_mines(mines_board, row, column)

    cond num_adjacent_mines do
      0 => nil,
      true => update_matrix(player_board, row, column, num_adjacent_mines)
    end
  end

  @doc """
    def count_mines(mines_board)

  """
  def count_mines(mines_board) do
    mines_board
    |> Enum.map(fn(x) -> Enum.filter(x, fn(y) -> y end) end) # filter mines for each row
    |> Enum.filter(fn(x) -> x != [] end) # filter rows without mines
    |> Enum.map(fn(x) -> Enum.map(x, fn(_y) -> 1 end) end) # attribute 1 to each mine
    |> Enum.map(fn(x) -> Enum.reduce(x, fn(y1, y2) -> y1 + y2 end) end) # count number of mines in each row
    |> Enum.reduce(fn(x, y) -> x + y end) # count total number of mines
  end

  @doc """

  """
  def generate_board(lenght) do

  end

  defp generate_board_step(lenght) do

  end

  defp generate_board_step2(lenght) do

  end

  @doc """
    Validate Move

    {x, y} = position

  """
  def validate_move(board, position) do
    {x, y} = position
  end

  def check_for_bomb(bomb_board, position) do
    {x, y} = position
  end

  def count_adjacent_bomb(bomb_board, position) do

  end

  def flag_positon(flag_board, position) do

  end
end
