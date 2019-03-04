defmodule Bpe.Jobs.Producer do
  @moduledoc """
  This is a simple producer that counts from the given
  number whenever there is a demand.
  """
  use GenStage
  require Logger

  def start_link(initial) do
    Logger.info "Producer start #{inspect initial}"
    GenStage.start_link(__MODULE__, initial, name: Producer)
  end

  def init(counter) do
    Logger.info "Producer init #{inspect counter}"
    {:producer, counter}
  end

  # def handle_demand(demand, state) when demand > 0 do
  #   # Logger.info inspect state
  #   events = Enum.to_list(1..10)
  #   # Logger.info "Producer handle demand #{inspect events}"
  #   {:noreply, events, state + demand}
  # end

  def handle_demand(demand, state) do
    Logger.info inspect demand
    Logger.info inspect state
    events = Enum.to_list(state..(state + demand - 1))
    {:noreply, events, state + demand}
  end
end
