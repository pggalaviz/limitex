defmodule LimitexTest do
  use ExUnit.Case

  @ip "127.0.0.1"

  test "returns error when limit is reached" do
    assert {:ok, 1} = Limitex.check_rate("upload:1", 60_000, 2)
    assert {:ok, 2} = Limitex.check_rate("upload:1", 60_000, 2)
    assert {:error, :rate_limited} = Limitex.check_rate("upload:1", 60_000, 2)
  end

  test "limit ends after time elapsed" do
    assert {:ok, 1} = Limitex.check_rate(@ip, 500, 2)
    assert {:ok, 2} = Limitex.check_rate(@ip, 500, 2)
    assert {:error, :rate_limited} = Limitex.check_rate(@ip, 500, 2)
    Process.sleep(600)
    assert {:ok, 1} = Limitex.check_rate(@ip, 500, 2)
  end

  test "limits faster if an arbitrary incremet is given" do
    assert {:ok, 1} = Limitex.check_rate(@ip, 60_000, 20)
    assert {:ok, 20} = Limitex.check_rate(@ip, 60_000, 20, 19)
    assert {:error, :rate_limited} = Limitex.check_rate(@ip, 60_000, 20)
  end
end
