defmodule Base64VLQ do
  use Bitwise

  @vlq_base_shift 5
  @vlq_base 1 <<< @vlq_base_shift
  @vlq_base_mask @vlq_base - 1
  @vlq_continuation_bit @vlq_base

  def encode(value) do
    vlq = to_vlq_signed(value)
    do_encode(vlq, "")
  end

  defp do_encode(vlq, encoded) do
    digit = vlq &&& @vlq_base_mask
    vlq = vlq >>> @vlq_base_shift

    digit = if vlq > 0 do
      digit ||| @vlq_continuation_bit
    else
      digit
    end

    {:ok, enc} = Base64.encode(digit)
    encoded = encoded <> enc

    if vlq > 0 do
      do_encode(vlq, encoded)
    else
      {:ok, encoded }
    end
  end

  def decode(value, index) do
    str_len = String.length(value)
    result = 0
    shift = 0

    case do_decode(value, result, shift, index, str_len) do
      {:error, _} = e ->
        e
      {:ok, value, index} ->
        {:ok, Map.new
        |> Map.put(:value, value)
        |> Map.put(:rest, index) }
    end
  end

  defp do_decode(_, _, _, index, str_len) when index >= length(str_len) do
    {:error, "Expected more digits in base 64 VLQ value."}
  end

  defp do_decode(value, result, shift, index, str_len) do
    char = String.at(value, index)
    <<char_code_at::utf8>> = char
    digit = Base64.decode(char_code_at)

    if digit == -1 do
      {:error, "Invalid base64 digit: #{ char }"}
    else
      continuation = digit &&& @vlq_continuation_bit
      digit = digit &&& @vlq_base_mask
      result = result + (digit <<< shift)
      shift = shift + @vlq_base_shift

      if continuation == 0 do
        {:ok, from_vlq_signed(result), index + 1}
      else
        do_decode(value, result, shift, index + 1, str_len)
      end
    end
  end

  defp to_vlq_signed(value) do
    case value < 0 do
      true ->
        (bnot(value) <<< 1) + 1
      _ ->
        (value <<< 1) + 0
    end
  end

  defp from_vlq_signed(value) do
    case (value &&& 1) == 1 do
      true ->
        bnot((value >>> 1))
      _ ->
        value >>> 1
    end
  end

end
