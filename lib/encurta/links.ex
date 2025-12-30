defmodule Encurta.Links do
  @moduledoc """
  The Links context.
  """

  import Ecto.Query, warn: false
  alias Encurta.Repo

  alias Encurta.Links.Url

  @short_generation_attempts 5

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
    |> insert_with_unique_short(@short_generation_attempts)
  end

  defp insert_with_unique_short(%Ecto.Changeset{} = changeset, 0) do
    changeset
    |> Ecto.Changeset.put_change(:short, generate_short_url())
    |> Repo.insert()
  end

  defp insert_with_unique_short(%Ecto.Changeset{} = changeset, attempts_left)
       when attempts_left > 0 do
    changeset = Ecto.Changeset.put_change(changeset, :short, generate_short_url())

    case Repo.insert(changeset) do
      {:ok, url} ->
        {:ok, url}

      {:error, %Ecto.Changeset{} = failed_changeset} ->
        if short_taken?(failed_changeset) do
          failed_changeset
          |> Ecto.Changeset.delete_change(:short)
          |> insert_with_unique_short(attempts_left - 1)
        else
          {:error, failed_changeset}
        end
    end
  end

  defp short_taken?(%Ecto.Changeset{errors: errors}) do
    Enum.any?(errors, fn
      {:short, {_msg, opts}} when is_list(opts) -> opts[:constraint] == :unique_constraint
      _ -> false
    end)
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
