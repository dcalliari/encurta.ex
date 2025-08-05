defmodule Encurta.Links.Url do
  use Ecto.Schema
  import Ecto.Changeset

  schema "urls" do
    field :short, :string
    field :url, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(url, attrs) do
    url
    |> cast(attrs, [:url, :short])
    |> validate_required([:url])
    |> validate_format(:url, ~r/^https?:\/\/.+/)
    |> unique_constraint(:short)
  end
end
