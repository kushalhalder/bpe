defmodule BpeWeb.SubscribeView do
  use BpeWeb, :view

  def render("index.json", _assigns) do
    %{no_errors: %{detail: "Consumer Started!"}}
  end

end
