defmodule Hello.Inn_check do
  use Ecto.Schema
  import Ecto.Changeset


  schema "inn_checks" do
    field :inn, :string
    field :result, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(inn_check, attrs) do
    inn_check
    |> cast(attrs, [:inn, :result])
    |> validate_required([:inn, :result])
  end
end
