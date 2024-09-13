defmodule SocketTest.ChatFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SocketTest.Chat` context.
  """

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        body: "some body",
        boosted: true,
        channel: "some channel",
        inserted_at: ~N[2024-09-12 09:19:00],
        user: "some user"
      })
      |> SocketTest.Chat.create_message()

    message
  end
end
