defmodule HelloWeb.CheckEgrul do
  def egrul_10_digits?(egrul_list_of_strings) do
    egrul_list_of_digits = for s <- egrul_list_of_strings, digit_1to9?(s), do: String.to_integer(s)
    case length(egrul_list_of_digits) === 10 do
      true ->
        [d1, d2, d3, d4, d5, d6, d7, d8, d9, tenth_digit] = egrul_list_of_digits

        remainder = get_remainder([2, 4, 10, 3, 5, 9, 4, 6, 8], [d1, d2, d3, d4, d5, d6, d7, d8, d9])
        case remainder === tenth_digit do
          true ->
            true

          false ->
            false
        end

      false ->
        false
    end
  end

  def egrul_12_digits?(egrul_list_of_strings) do
    egrul_list_of_digits = for s <- egrul_list_of_strings, digit_1to9?(s), do: String.to_integer(s)
    case length(egrul_list_of_digits) === 12 do
      true ->
        [d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, eleventh_digit, twelfth_digit] = egrul_list_of_digits

        remainder1 = get_remainder([7, 2, 4, 10, 3, 5, 9, 4, 6, 8], [d1, d2, d3, d4, d5, d6, d7, d8, d9, d10])
        remainder2 = get_remainder([3, 7, 2, 4, 10, 3, 5, 9, 4, 6, 8], [d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, eleventh_digit])
        case remainder1 === eleventh_digit and remainder2 === twelfth_digit do
          true ->
            true

          false ->
            false
        end

      false ->
        false
    end
  end

  defp digit_1to9?(string) do
    parsed_string = Integer.parse(string)
    case parsed_string do
      :error ->
        false

      _ ->
        true
    end
  end

  defp get_remainder(list1, list2) do
    zipped_list = Enum.zip(list1, list2)
    {_, sum} = Enum.map_reduce(zipped_list, 0, fn {x, y}, acc -> {{}, x * y + acc} end)
    remainder_temp = rem(sum, 11)
    case remainder_temp === 10 do
      true ->
        0

      false ->
        remainder_temp
    end
  end
end
