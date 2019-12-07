defmodule Gekko.Repo do
  use Ecto.Repo,
    otp_app: :gekko,
    adapter: Ecto.Adapters.Postgres
end
