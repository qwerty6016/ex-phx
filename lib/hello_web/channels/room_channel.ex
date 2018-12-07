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
        true ->
          broadcast!(socket, "egrul_checked", %{date_time: NaiveDateTime.to_string(check.inserted_at), inn: check.inn, result: "корректен"})

        false ->
          broadcast!(socket, "egrul_checked", %{date_time: NaiveDateTime.to_string(check.inserted_at), inn: check.inn, result: "некорректен"})
      end
    end)

    {:noreply, socket}
  end

  def handle_in("check_egrul", %{"body" => body}, socket) do
    body_as_list = String.codepoints(body)
    correct = case length(body_as_list) do
      10 ->
        HelloWeb.CheckEgrul.egrul_10_digits?(body_as_list)

      12 ->
        HelloWeb.CheckEgrul.egrul_12_digits?(body_as_list)

      _  ->
        false
    end

    check = %Hello.Inn_check{}
    changeset = Hello.Inn_check.changeset(check, %{inn: body, result: correct})
    case Hello.Repo.insert(changeset) do
      {:ok, check} -> case correct do
        true ->
          broadcast!(socket, "egrul_checked", %{date_time: NaiveDateTime.to_string(check.inserted_at), inn: check.inn, result: "корректен"})

        false ->
          broadcast!(socket, "egrul_checked", %{date_time: NaiveDateTime.to_string(check.inserted_at), inn: check.inn, result: "некорректен"})
      end

      {:error, changeset} ->
        Logger.error "Hello.Repo.insert(changeset) error"
    end

    {:noreply, socket}
  end
end
