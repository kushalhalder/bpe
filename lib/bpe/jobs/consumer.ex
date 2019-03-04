defmodule Bpe.Jobs.Consumer do
  @moduledoc """
  A consumer will be a consumer supervisor that will
  spawn printer tasks for each event.
  """

  use GenStage
  require Logger

  def start_link, do: start_link([])
  def start_link(_), do: GenStage.start_link(__MODULE__, :ok)

  def init(state) do
    Logger.info "Consumer init #{inspect state}}"
    {:consumer, state}
  end

  def init(:ok) do
    {:consumer, :state_does_not_matter}
  end

  def handle_events(events, _from, state) do
    Logger.info inspect(events)

    {:noreply, [], state}
  end

end
