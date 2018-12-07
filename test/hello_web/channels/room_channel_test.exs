defmodule HelloWeb.RoomChannelTest do
  use HelloWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      socket(HelloWeb.UserSocket, "user_id", %{some: :assign})
      |> subscribe_and_join(HelloWeb.RoomChannel, "room:lobby")

    {:ok, socket: socket}
  end

  test "shout check_egrul correct 12-digit with rem 3 and 10", %{socket: socket} do
    push socket, "check_egrul", %{"body" => "732897853530"}
    assert_broadcast "egrul_checked", %{inn: "732897853530", result: "корректен"}
  end

  test "shout check_egrul correct 12-digit with rem 9 and 9", %{socket: socket} do
    push socket, "check_egrul", %{"body" => "622894076999"}
    assert_broadcast "egrul_checked", %{inn: "622894076999", result: "корректен"}
  end

  test "shout check_egrul correct 10-digit with rem 0", %{socket: socket} do
    push socket, "check_egrul", %{"body" => "1111111170"}
    assert_broadcast "egrul_checked", %{inn: "1111111170", result: "корректен"}
  end

  test "shout check_egrul incorrect 12-digit", %{socket: socket} do
    push socket, "check_egrul", %{"body" => "11111www1111"}
    assert_broadcast "egrul_checked", %{inn: "11111www1111", result: "некорректен"}
  end

  test "shout check_egrul incorrect 10-digit", %{socket: socket} do
    push socket, "check_egrul", %{"body" => "1010101010"}
    assert_broadcast "egrul_checked", %{inn: "1010101010", result: "некорректен"}
  end

  test "shout check_egrul incorrect 9-digit", %{socket: socket} do
    push socket, "check_egrul", %{"body" => "999999999"}
    assert_broadcast "egrul_checked", %{inn: "999999999", result: "некорректен"}
  end

  test "shout check_egrul incorrect 13-digit", %{socket: socket} do
    push socket, "check_egrul", %{"body" => "13131313130"}
    assert_broadcast "egrul_checked", %{inn: "13131313130", result: "некорректен"}
  end
end
