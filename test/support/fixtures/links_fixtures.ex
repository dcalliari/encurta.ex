defmodule Encurta.LinksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Encurta.Links` context.
  """

  @doc """
  Generate a url.
  """
  def url_fixture(attrs \\ %{}) do
    {:ok, url} =
      attrs
      |> Enum.into(%{
        short: "some short",
        url: "some url"
      })
      |> Encurta.Links.create_url()

    url
  end
end
