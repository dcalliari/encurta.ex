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
    |> cast(attrs, [:url])
    |> validate_required([:url])
    |> update_change(:url, &normalize_url/1)
    |> validate_length(:url, max: 2048)
    |> validate_change(:url, &validate_url/2)
    |> unique_constraint(:short)
  end

  defp normalize_url(url) when is_binary(url), do: String.trim(url)
  defp normalize_url(url), do: url

  defp validate_url(:url, url) when is_binary(url) do
    cond do
      url == "" ->
        [url: "can't be blank"]

      String.contains?(url, ["\r", "\n", "\t", " "]) ->
        [url: "must not contain whitespace"]

      true ->
        uri = URI.parse(url)

        cond do
          uri.scheme not in ["http", "https"] ->
            [url: "must start with http:// or https://"]

          is_nil(uri.host) or uri.host == "" ->
            [url: "must include a valid host"]

          true ->
            []
        end
    end
  end

  defp validate_url(:url, _), do: [url: "is invalid"]
end
