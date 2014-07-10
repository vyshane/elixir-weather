defmodule WeatherTest do
  use ExUnit.Case

  import Weather.CLI, only: [parse_args: 1]

  test ":help returned for -h and --help" do
    assert parse_args(["-h", "anything"]) == :help
    assert parse_args(["--help", "anything"]) == :help
  end
end
