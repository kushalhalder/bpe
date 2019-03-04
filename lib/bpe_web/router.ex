defmodule BpeWeb.Router do
  use BpeWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BpeWeb do
    pipe_through :api

    get "/activate-jobs", ActivateJobsController, :index
    get "/subscribe-to-topic", SubscribeController, :index

  end
end
