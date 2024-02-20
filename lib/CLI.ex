defmodule Minesweeper.CLI do
  @moduledoc """

  """

  @doc """

  """
  def main(args \\ []) do
    board = [
      []
    ]

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

  end
end
