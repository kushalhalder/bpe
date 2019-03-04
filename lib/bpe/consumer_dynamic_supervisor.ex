defmodule Bpe.ConsumerDynamicSupervisor do
  @moduledoc false

  use DynamicSupervisor

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def start_child(topic_name, worker_id) do
    spec = {Bpe.Jobs.Consumer, topic_name: topic_name, worker_id: worker_id}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
  
  @impl true
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

end
