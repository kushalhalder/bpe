defmodule BpeWeb.SubscribeController do
  @moduledoc false

  use BpeWeb, :controller
  require Logger

  def index(conn, params) do
    spec = %{id: Bpe.TaskDemandHandling.Consumer, start: {Bpe.TaskDemandHandling.Consumer, :start_link, [params["topic_name"]]}}
    {:ok, variable} = DynamicSupervisor.start_child(Bpe.DynamicSupervisor, spec)
    render(conn, "index.json")
  end

end
