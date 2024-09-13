defmodule SocketTest.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :user, :string
    field :body, :string
    field :boosted, :boolean, default: false
    field :channel, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    # Exclude :inserted_at from cast
    |> cast(attrs, [:body, :user, :boosted, :channel])
    # Exclude :inserted_at from validation
    |> validate_required([:body, :user, :channel])
  end
end
