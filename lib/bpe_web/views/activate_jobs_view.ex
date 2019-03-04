defmodule BpeWeb.ActivateJobsView do
  use BpeWeb, :view

  def render("index.json", _assigns) do
    %{no_errors: %{detail: "Hi!"}}
  end

end
