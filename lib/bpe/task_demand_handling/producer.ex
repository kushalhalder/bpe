defmodule Bpe.TaskDemandHandling.Producer do
  use GenStage

  def start_link, do: start_link([])
  def start_link(_), do: GenStage.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok) do
    state = %{events: [], demand: 0}

    {:producer, state, []}
  end

  def handle_info(_, state), do: {:noreply, [], state}

  # receives a demand, adds it to the state
  # and invokes events dispatching function
  def handle_demand(incoming_demand, %{demand: demand} = state) do
    new_state = Map.put(state, :demand, demand + incoming_demand)

    dispatch_events(new_state)
  end

  # if events amount is enough to cover the demand:
  # 1. get the needed amount of events
  # 2. reset the demand
  # 3. save zero-demand and remaining events in the state
  defp dispatch_events(%{events: events, demand: demand} = state)
       when length(events) >= demand
  do
    {events_to_dispatch, remaining_events} = Enum.split(events, demand)

    new_state =
      state
      |> Map.put(:demand, 0)
      |> Map.put(:events, remaining_events)

    {:noreply, events_to_dispatch, new_state}
  end
  # if events amount doesnt cover the demand:
  # 1. fetch more events (events amount equals to the demand)
  # 2. saves demand and events in the state
  # 3. invokes dispath_events/1 again (now the demand should be covered)
  defp dispatch_events(%{events: events, demand: demand} = state)
       when length(events) < demand
  do
    events = events ++ fetch_events(demand)

    state
    |> Map.put(:demand, demand)
    |> Map.put(:events, events)
    |> dispatch_events()
  end

  defp fetch_events(demand) do
    map = %{key: UUID.uuid1(), value: UUID.uuid1()}
    protobuf_map = Bpe.MessagePayload.ConsumerEvent.TaskPayload.new(map)
    encoded = Bpe.MessagePayload.ConsumerEvent.TaskPayload.encode(protobuf_map)
    List.duplicate(encoded, demand)
  end
end
