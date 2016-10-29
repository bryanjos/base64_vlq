defmodule Base64 do
  @int_to_char_map String.split("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/", "", trim: true)

  def encode(number) when 0 <= number and number < length(@int_to_char_map) do
    { :ok, Enum.at(@int_to_char_map, number) }
  end

  def encode(_) do
    :error
  end

  def decode(char_code) do
    little_offset = 26
    number_offset = 52

    cond do
      ?A <= char_code and char_code <= ?Z ->
        char_code - ?A
      ?a <= char_code and char_code <= ?z ->
        char_code - ?a + little_offset
      ?0 <= char_code and char_code <= ?9 ->
        char_code - ?0 + number_offset
      char_code == ?+ ->
        62
      char_code == ?/ ->
        63
      true ->
        -1
    end

  end

end
