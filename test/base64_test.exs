defmodule Base64Test do
  use ExUnit.Case
  doctest Base64

  test "out of range encoding" do
    assert :error == Base64.encode(-1)
    assert :error == Base64.encode(64)
  end

  test "out of range decoding" do
    assert -1 == Base64.decode(?=)
  end

  test "test normal encoding and decoding" do
    Enum.each(0..63, fn i ->
      { :ok, encoded } = Base64.encode(i)
      <<codepoint::utf8>> = encoded
      decoded = Base64.decode(codepoint)

      assert decoded == i
    end)
  end
end
