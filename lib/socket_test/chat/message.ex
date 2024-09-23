defmodule SocketTest.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [:id, :user, :body, :boosted, :channel, :inserted_at, :updated_at]}
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
    |> cast(attrs, [:body, :user, :boosted, :channel])
    |> validate_required([:body, :user, :channel])
  end
end
