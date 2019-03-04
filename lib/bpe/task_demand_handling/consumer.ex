defmodule Bpe.TaskDemandHandling.Consumer do
  use GenStage
  alias Bpe.Connectors.Redix, as: Redix

  require Logger

  @min_demand 1
  @max_demand 4

  def start_link, do: start_link([])
  def start_link(topic_name), do: GenStage.start_link(__MODULE__, topic_name)

  def init(topic_name) do
    # Ask for events on a given interval
    interval = 1000

    state = %{
      producer: Bpe.TaskDemandHandling.Producer,
      subscription: nil,
      poll_interval: interval,
      topic_name: topic_name
    }

    GenStage.async_subscribe(
      self(),
      to: state.producer,
      min_demand: @min_demand,
      max_demand: @max_demand
    )

    response = Process.send_after(self(), :ask, state[:poll_interval])
    Logger.info inspect response

    {:consumer, state}
  end

  def handle_subscribe(:producer, _opts, from, state) do
    {:manual, Map.put(state, :subscription, from)}
  end

  def handle_info(:init_ask, %{subscription: subscription} = state) do
    Logger.info("Ask for events")
    GenStage.ask(subscription, @max_demand)

    {:noreply, [], state}
  end

  def handle_info(:ask, state) do
    if (ask_for_more(state[:topic_name])) do
      # Request a batch of events with a max batch size
      GenStage.ask(state[:subscription], @max_demand)
      Logger.info("Topic name asked for more")
    end
    # Schedule the next request
    Process.send_after(self(), :ask, state[:poll_interval])
    {:noreply, [], state}
  end

  def handle_info(_, state), do: {:noreply, [], state}

  def handle_events(events, _from, %{topic_name: topic_name} = state)
      when is_list(events)
  do
    # events handling here
    for event <- events do
      # send each event to stream with topic name
      # redis-cli > XADD topic * data
      {:ok, response} = Redix.command(["XADD", topic_name, "*", "event", event])
      Logger.info("Message to Stream #{inspect response}")
    end

    {:noreply, [], state}
  end

  def handle_events(_events, _from, state), do: {:noreply, [], state}

  defp ask_for_more(topic_name) do
    # Check Stream length
    {:ok, response} = Redix.command(["XLEN", topic_name])
    Logger.info("Stream consumption: Topic #{topic_name} => #{response}")
    response < @max_demand
  end
end
