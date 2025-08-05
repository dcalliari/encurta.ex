defmodule Encurta.LinksTest do
  use Encurta.DataCase

  alias Encurta.Links

  describe "urls" do
    alias Encurta.Links.Url

    import Encurta.LinksFixtures

    @invalid_attrs %{short: nil, url: nil}

    test "list_urls/0 returns all urls" do
      url = url_fixture()
      assert Links.list_urls() == [url]
    end

    test "get_url!/1 returns the url with given id" do
      url = url_fixture()
      assert Links.get_url!(url.id) == url
    end

    test "create_url/1 with valid data creates a url" do
      valid_attrs = %{short: "some short", url: "some url"}

      assert {:ok, %Url{} = url} = Links.create_url(valid_attrs)
      assert url.short == "some short"
      assert url.url == "some url"
    end

    test "create_url/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Links.create_url(@invalid_attrs)
    end

    test "update_url/2 with valid data updates the url" do
      url = url_fixture()
      update_attrs = %{short: "some updated short", url: "some updated url"}

      assert {:ok, %Url{} = url} = Links.update_url(url, update_attrs)
      assert url.short == "some updated short"
      assert url.url == "some updated url"
    end

    test "update_url/2 with invalid data returns error changeset" do
      url = url_fixture()
      assert {:error, %Ecto.Changeset{}} = Links.update_url(url, @invalid_attrs)
      assert url == Links.get_url!(url.id)
    end

    test "delete_url/1 deletes the url" do
      url = url_fixture()
      assert {:ok, %Url{}} = Links.delete_url(url)
      assert_raise Ecto.NoResultsError, fn -> Links.get_url!(url.id) end
    end

    test "change_url/1 returns a url changeset" do
      url = url_fixture()
      assert %Ecto.Changeset{} = Links.change_url(url)
    end
  end
end
