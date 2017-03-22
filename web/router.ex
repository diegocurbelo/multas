defmodule Multas.Router do
  use Multas.Web, :router

  require Logger

  pipeline :bot do
    plug :accepts, ["json"]
    plug :verify_signature
  end

  scope "/bot", Multas do
    pipe_through :bot

    get  "/facebook", Bot.FacebookController, :validate
    post "/facebook", Bot.FacebookController, :webhook
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Multas do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Multas do
  #   pipe_through :api
  # end

  # --

  defp verify_signature(conn, _) do
    signature = get_req_header(conn, "x-hub-signature")
    if is_binary(signature) do
      ["sha1=" <> signature] = signature
      hmac = :crypto.hmac(:sha, Application.get_env(:multas, :facebook)[:app_secret], conn.private[:raw_body])
             |> Base.encode16
             |> String.downcase

      if hmac != signature do
          Logger.log :warn, "Couldn't validate the request signature"
          send_resp(conn, :unauthorized, "Not authorized") |> halt
      # else
      #   conn = put_private(conn, :raw_body, nil)
      end
    end
    conn
  end

end
