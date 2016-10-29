defmodule Base64VLQTest do
  use ExUnit.Case
  doctest Base64VLQ

  test "test normal encoding and decoding" do

    Enum.each(-255..255, fn i ->
      IO.inspect i

      {:ok, str } = Base64VLQ.encode(i)
      |> IO.inspect(label: "encode")

      {:ok, result } = Base64VLQ.decode(str, 0)
      |> IO.inspect(label: "decode")

      assert result.value == i
      assert result.rest == String.length(str)
    end)

  end
end
