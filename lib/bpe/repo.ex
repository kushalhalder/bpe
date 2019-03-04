defmodule Bpe.Repo do
  use Ecto.Repo,
    otp_app: :bpe,
    adapter: Ecto.Adapters.MySQL
end
