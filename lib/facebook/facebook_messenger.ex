defmodule FacebookMessenger do
  require Logger

  alias Multas.{Repo, Log}

  def send_typing(recipient, state \\ "on") do
    %{recipient: %{id: recipient},
      sender_action: "typing_#{state}"}
    |> send
  end

  def send_message(recipient, message) do
    Repo.insert! Log.changeset(%Log{}, %{to: recipient, content: message})
    %{recipient: %{id: recipient},
      message: %{text: message}}
    |> send
  end

  def send_quick_reply(recipient, message, replies) do
    Repo.insert! Log.changeset(%Log{}, %{to: recipient, content: message})
    %{recipient: %{id: recipient},
      message: %{text: message, quick_replies: replies}}
    |> send
  end

  def send_quick_reply_yes_or_no(recipient, message) do
    replies = [quick_reply("Si", "https://s27.postimg.org/6o0tt3ubj/image.jpg"),
               quick_reply("No", "https://s27.postimg.org/uqhnnzayn/image.jpg")]
    send_quick_reply(recipient, message, replies)
  end

  def quick_reply(title, image_url) do
    %{content_type: "text", title: title, payload: title, image_url: image_url}
  end
  

  # --

  defp send(message) do
    page_access_token = Application.get_env(:multas, :facebook)[:page_access_token]
    url = "https://graph.facebook.com/v2.6/me/messages?access_token=#{page_access_token}"

    message = message |> Poison.encode!

    response = HTTPoison.post(url, message, [{"Content-Type", "application/json"}])
    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        :ok
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        Logger.error "Unable to send message to recepient: status = #{status_code}, body: #{body}"
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error "Unable to send message to recepient': #{reason}"
    end
  end

end
