defmodule Multas.Bot.FacebookController do
  use Multas.Web, :controller

  require Logger

  alias Multas.Helpers.Facebook


  def validate(conn, %{"hub.mode" => "subscribe",
                       "hub.verify_token" => verify_token,
                       "hub.challenge" => challenge}) do
    if verify_token == "diego" do
      html conn, challenge
    else
      send_resp conn, 403, ""
    end
  end
  def validate(conn, _), do: send_resp conn, 403, ""


  def webhook(conn, %{"entry" => entry, "object" => "page"}) do
    # Iterate over each entry, there may be multiple if batched
    for page_entry <- entry do
      for messaging_event <- page_entry["messaging"] do
        spawn(Facebook, :process, [messaging_event])
      end
    end
    send_resp conn, 200, ""
  end

end
