defmodule SocketTest.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @max_amount_of_messages_to_fetch 100

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

  def fetch_latest_messages(repo, id \\ nil, amount) do
    IO.puts("#{repo}, #{id}, #{amount}")

    messages =
      case id do
        nil ->
          # If id is nil, fetch the latest messages directly
          from(m in __MODULE__,
            order_by: [desc: m.id],
            limit: ^min(amount, @max_amount_of_messages_to_fetch)
          )
          |> repo.all()

        _ ->
          # If id is provided, use the existing logic to filter messages
          from(m in __MODULE__,
            where: m.id < ^id,
            order_by: [desc: m.id],
            limit: ^min(amount, @max_amount_of_messages_to_fetch)
          )
          |> repo.all()
      end

    messages
  end

end
