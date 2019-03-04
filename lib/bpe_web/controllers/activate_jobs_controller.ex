defmodule BpeWeb.ActivateJobsController do
  use BpeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.json");
  end

end
