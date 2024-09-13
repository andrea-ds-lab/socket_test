defmodule SocketTest.ChatTest do
  use SocketTest.DataCase

  alias SocketTest.Chat

  describe "messages" do
    alias SocketTest.Chat.Message

    import SocketTest.ChatFixtures

    @invalid_attrs %{user: nil, body: nil, boosted: nil, inserted_at: nil, channel: nil}

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Chat.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Chat.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      valid_attrs = %{
        user: "some user",
        body: "some body",
        boosted: true,
        inserted_at: ~N[2024-09-12 09:19:00],
        channel: "some channel"
      }

      assert {:ok, %Message{} = message} = Chat.create_message(valid_attrs)
      assert message.user == "some user"
      assert message.body == "some body"
      assert message.boosted == true
      assert message.inserted_at == ~N[2024-09-12 09:19:00]
      assert message.channel == "some channel"
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chat.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()

      update_attrs = %{
        user: "some updated user",
        body: "some updated body",
        boosted: false,
        inserted_at: ~N[2024-09-13 09:19:00],
        channel: "some updated channel"
      }

      assert {:ok, %Message{} = message} = Chat.update_message(message, update_attrs)
      assert message.user == "some updated user"
      assert message.body == "some updated body"
      assert message.boosted == false
      assert message.inserted_at == ~N[2024-09-13 09:19:00]
      assert message.channel == "some updated channel"
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Chat.update_message(message, @invalid_attrs)
      assert message == Chat.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Chat.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Chat.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Chat.change_message(message)
    end
  end
end
