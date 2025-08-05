defmodule Encurta.Repo do
  use Ecto.Repo,
    otp_app: :encurta,
    adapter: Ecto.Adapters.Postgres
end
