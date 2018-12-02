defmodule HelloWeb.RoomChannel do
  use Phoenix.Channel
  require Logger

  def join("room:lobby", _message, socket) do
	{:ok, socket}
  end
  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end
  
  def handle_in("get_previous_checks", _message, socket) do
    checks = Hello.Inn_check |> Hello.Repo.all
	Enum.each(checks, fn (check) -> 
	                      case check.result do
	                          true -> broadcast!(socket, "egrul_checked", %{body: "[" <> NaiveDateTime.to_string(check.inserted_at) <> "] " <> check.inn <> " : корректен"})
	                          false -> broadcast!(socket, "egrul_checked", %{body: "[" <> NaiveDateTime.to_string(check.inserted_at) <> "] " <> check.inn <> " : некорректен"})
                          end
					  end)
	{:noreply, socket}
  end
  
  def handle_in("check_egrul", %{"body" => body}, socket) do
	body_as_list = String.codepoints(body)
	correct = case length(body_as_list) do
	    10 -> egrul_10_digits?(body_as_list)
		12 -> egrul_12_digits?(body_as_list)
		_  -> false
	end
	check = %Hello.Inn_check{}
    changeset = Hello.Inn_check.changeset(check, %{inn: body, result: correct})
	case Hello.Repo.insert(changeset) do
        {:ok, check} -> case correct do
	                        true -> broadcast!(socket, "egrul_checked", %{body: "[" <> NaiveDateTime.to_string(check.inserted_at) <> "] " <> check.inn <> " : корректен"})
	                        false -> broadcast!(socket, "egrul_checked", %{body: "[" <> NaiveDateTime.to_string(check.inserted_at) <> "] " <> check.inn <> " : некорректен"})
                        end
        {:error, changeset} -> Logger.error "Hello.Repo.insert(changeset) error"
    end
	{:noreply, socket}
  end
  
  defp egrul_10_digits?(egrul_list_of_strings) do
	  egrul_list_of_digits = for s <- egrul_list_of_strings, digit_1to9?(s), do: String.to_integer(s)
	  cond do
	      length(egrul_list_of_digits) === 10 -> [d1, d2, d3, d4, d5, d6, d7, d8, d9, tenth_digit] = egrul_list_of_digits
		      remainder_temp = rem(d1 * 2 + d2 * 4 + d3 * 10 + d4 * 3 + d5 * 5 + d6 * 9 + d7 * 4 + d8 * 6 + d9 * 8, 11)
		      remainder = cond do 
			      remainder_temp > 9 -> remainder_temp / 10
				  true -> remainder_temp
			  end
			  cond do
			      remainder === tenth_digit -> true
				  true -> false
			  end
		  true -> false
	  end
  end
  
  defp egrul_12_digits?(egrul_list_of_strings) do
      egrul_list_of_digits = for s <- egrul_list_of_strings, digit_1to9?(s), do: String.to_integer(s)
	  cond do
	      length(egrul_list_of_digits) === 12 -> [d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, eleventh_digit, twelfth_digit] = egrul_list_of_digits
		      remainder1_temp = rem(d1 * 7 + d2 * 2 + d3 * 4 + d4 * 10 + d5 * 3 + d6 * 5 + d7 * 9 + d8 * 4 + d9 * 6 + d10 * 8, 11)
		      remainder1 = cond do
			      remainder1_temp > 9 -> remainder1_temp / 10
				  true -> remainder1_temp
			  end
			  remainder2_temp = rem(d1 * 3 + d2 * 7 + d3 * 2 + d4 * 4 + d5 * 10 + d6 * 3 + d7 * 5 + d8 * 9 + d9 * 4 + d10 * 6 + eleventh_digit * 8, 11)
		      remainder2 = cond do
			      remainder2_temp > 9 -> remainder2_temp / 10
				  true -> remainder2_temp
			  end
			  cond do
			      remainder1 === eleventh_digit and remainder2 === twelfth_digit -> true
				  true -> false
			  end
		  true -> false
	  end
  end
  
  defp digit_1to9?(string) do
	  parsed_string = Integer.parse(string)
	  case parsed_string do
	      :error -> false
		  _ -> true
	  end
  end
end