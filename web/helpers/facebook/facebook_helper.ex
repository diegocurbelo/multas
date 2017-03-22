defmodule Multas.Helpers.Facebook do
  require Logger

  # import Ecto.Query, only: [from: 2]

  alias Multas.{Repo, Log, Sender}
  alias Multas.Helpers.AI


  def process(event) do
    %{"sender" => %{"id" => sender_id}} = event

    case event do
      %{"message" => %{"text" => text}} ->
        FacebookMessenger.send_typing(sender_id)
        Repo.insert! Log.changeset(%Log{}, %{from: sender_id, content: text})
        process_message(sender_id, text)

      %{"message" => %{"sticker_id" => sticker_id}} ->
        Repo.insert! Log.changeset(%Log{}, %{from: sender_id, content: "sticker_id: #{sticker_id}"})
        FacebookMessenger.send_message(sender_id, ";)")

      %{"postback" => %{"payload" => answer}} ->
        Logger.info "Received 'postback'"

      # %{"optin" => %{"ref" => ref_data}} ->
      #   Logger.info "Received 'optin'"
      #
      # %{"referral" => %{"ref" => ref_data}} ->
      #   Logger.info "Received 'referral'"

      _ ->
        Logger.error "Not handling FB message"
    end

  end

  # --

  defp process_message(facebook_id, text) do
    sender =
      case Repo.get_by(Sender, facebook_id: facebook_id) do
        nil ->
          Sender.changeset(%Sender{}, %{facebook_id: facebook_id}) |> Repo.insert!
        struct ->
          struct
      end

    case AI.parse_intent(sender, text) do
      {:query, plate} ->
        AI.Query.execute(sender, plate)

      {:subscribe, plate} ->
        AI.Notifications.subscribe(sender, plate)

      {:unsubscribe, plate} ->
        AI.Notifications.unsubscribe(sender, plate)

      {:thanks} ->
        FacebookMessenger.send_message(facebook_id, "👍")

      _ ->
        FacebookMessenger.send_message(facebook_id, "Qué matrícula deseas consultar?")
    end
  end

end
