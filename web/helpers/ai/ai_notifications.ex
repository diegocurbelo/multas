defmodule Multas.Helpers.AI.Notifications do

  import Ecto.Query, only: [from: 2]

  alias Multas.{Repo, Sender, TrafficTicket, Notification}


  def subscribe(sender, plate) do
    update_notification_info(sender, plate, true)

    context = %{"action" => "subscription_confirmed", "plate" => plate} |> Poison.encode!
    Ecto.Changeset.change(sender, context: context) |> Repo.update!

    FacebookMessenger.send_message(sender.facebook_id, "Las multas se publican semanalmente, si #{plate} aparece en la lista recibirás un mensaje.")
  end

  def unsubscribe(sender, plate) do
    update_notification_info(sender, plate, false)

    context = %{"action" => "subscription_rejected", "plate" => plate} |> Poison.encode!
    Ecto.Changeset.change(sender, context: context) |> Repo.update!

    FacebookMessenger.send_message(sender.facebook_id, "Ya no recibirás notificaciones para la matrícula #{plate}")
  end

  # --

  defp update_notification_info(sender, plate, status) do
    search_plate = String.replace(plate, " ", "")
    case Repo.get_by(Notification, [facebook_id: sender.facebook_id, plate: search_plate]) do
      nil  -> %Notification{facebook_id: sender.facebook_id, plate: search_plate}
      notification -> notification
    end
    |> Notification.changeset(%{active: status})
    |> Repo.insert_or_update
  end
end
