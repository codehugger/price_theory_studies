defmodule Threadneedle.Repo do
  use Ecto.Repo,
    otp_app: :threadneedle,
    adapter: Ecto.Adapters.Postgres
end
