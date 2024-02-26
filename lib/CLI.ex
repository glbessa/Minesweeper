defmodule Minesweeper.CLI do
  import Minesweeper.Utils

  @moduledoc """

  """

  @doc """

  """
  def main(args \\ []) do
    board = [
      [1,2],
      [3,4]
    ]

    IO.inspect(Minesweeper.Utils.update_array([1,2,3], 1, 1), :as_lists)

    IO.puts("Olá mundo!")
  end

  @doc """

  """
  defp parse_args(args) do
    {} =
      args
      |> OptionParser.parse()

  end

  defp process_command(command) do

    IO.gets("")
    process_command()
  end

  defp parse_command(command) do

  end
end
