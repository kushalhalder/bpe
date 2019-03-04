defmodule Bpe.MessagePayload.ConsumerEvent do
  use Protobuf, """
    message TaskPayload {
      string key = 1;
      string value = 2;
    }
  """
end
