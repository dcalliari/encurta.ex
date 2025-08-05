defmodule Encurta.Links do
  @moduledoc """
  The Links context.
  """

  import Ecto.Query, warn: false
  alias Encurta.Repo

  alias Encurta.Links.Url

  @doc """
  Returns the list of urls.

  ## Examples

      iex> list_urls()
      [%Url{}, ...]

  """
  def list_urls do
    Repo.all(Url)
  end

  @doc """
  Gets a single url.

  Raises `Ecto.NoResultsError` if the Url does not exist.

  ## Examples

      iex> get_url!(123)
      %Url{}

      iex> get_url!(456)
      ** (Ecto.NoResultsError)

  """
  def get_url!(id), do: Repo.get!(Url, id)

  @doc """
  Gets a single url by short code.

  Returns the url if found, otherwise returns nil.

  ## Examples

      iex> get_url_by_short("abc123")
      %Url{}

      iex> get_url_by_short("notfound")
      nil

  """
  def get_url_by_short(short) do
    Repo.get_by(Url, short: short)
  end

  @doc """
  Creates a url.

  ## Examples

      iex> create_url(%{field: value})
      {:ok, %Url{}}

      iex> create_url(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_url(attrs \\ %{}) do
    %Url{}
    |> Url.changeset(attrs)
    |> Ecto.Changeset.put_change(:short, generate_short_url())
    |> Repo.insert()
  end

  @doc """
  Updates a url.

  ## Examples

      iex> update_url(url, %{field: new_value})
      {:ok, %Url{}}

      iex> update_url(url, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_url(%Url{} = url, attrs) do
    url
    |> Url.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a url.

  ## Examples

      iex> delete_url(url)
      {:ok, %Url{}}

      iex> delete_url(url)
      {:error, %Ecto.Changeset{}}

  """
  def delete_url(%Url{} = url) do
    Repo.delete(url)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking url changes.

  ## Examples

      iex> change_url(url)
      %Ecto.Changeset{data: %Url{}}

  """
  def change_url(%Url{} = url, attrs \\ %{}) do
    Url.changeset(url, attrs)
  end

  @doc """
  Generates a random short URL.

  ## Examples

      iex> generate_short_url()
      "abc12345"
  """
  def generate_short_url do
    :crypto.strong_rand_bytes(6)
    |> Base.url_encode64(padding: false)
    |> String.slice(0, 8)
  end
end
