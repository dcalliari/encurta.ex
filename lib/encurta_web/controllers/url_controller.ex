defmodule EncurtaWeb.UrlController do
  use EncurtaWeb, :controller

  alias Encurta.Links
  alias Encurta.Links.Url

  def index(conn, _params) do
    urls = Links.list_urls()
    render(conn, :index, urls: urls)
  end

  def new(conn, _params) do
    changeset = Links.change_url(%Url{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"url" => url_params}) do
    case Links.create_url(url_params) do
      {:ok, url} ->
        conn
        |> put_flash(:info, "Url created successfully.")
        |> redirect(to: ~p"/urls/#{url}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    url = Links.get_url!(id)
    render(conn, :show, url: url)
  end

  def edit(conn, %{"id" => id}) do
    url = Links.get_url!(id)
    changeset = Links.change_url(url)
    render(conn, :edit, url: url, changeset: changeset)
  end

  def update(conn, %{"id" => id, "url" => url_params}) do
    url = Links.get_url!(id)

    case Links.update_url(url, url_params) do
      {:ok, url} ->
        conn
        |> put_flash(:info, "Url updated successfully.")
        |> redirect(to: ~p"/urls/#{url}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, url: url, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    url = Links.get_url!(id)
    {:ok, _url} = Links.delete_url(url)

    conn
    |> put_flash(:info, "Url deleted successfully.")
    |> redirect(to: ~p"/urls")
  end

  def redirect_by_short(conn, %{"short" => short}) do
    case Links.get_url_by_short(short) do
      nil ->
        conn
        |> put_flash(:error, "Short URL not found.")
        |> redirect(to: ~p"/urls")

      url ->
        conn
        |> redirect(external: url.url)
    end
  end
end
