defmodule Multas.Helpers.AI.Query do

  import Ecto.Query, only: [from: 2]

  alias Multas.{Repo, Sender, TrafficTicket, Notification}


  def execute(sender, plate) do
    search_plate = String.replace(plate, " ", "")

    tickets = Repo.all(from t in TrafficTicket, where: [plate: ^search_plate], select: t)
    if tickets == [] do
      FacebookMessenger.send_message(sender.facebook_id, "No hay multas electrónicas para la matrícula #{plate}.")

    else
      Enum.each(tickets, fn(ticket) ->
          FacebookMessenger.send_message(sender.facebook_id, "Multa para la matrícula #{plate} del día #{ticket.date} en #{ticket.location} por #{ticket.reason}.")
      end)
      FacebookMessenger.send_message(sender.facebook_id, "Puedes verificar las fotos en http://www.montevideo.gub.uy/consultainfracciones")
    end

    notif = Repo.get_by(Notification, [facebook_id: sender.facebook_id, plate: search_plate])
    if notif == nil || !notif.active do
      FacebookMessenger.send_quick_reply_yes_or_no(sender.facebook_id, "Quieres que te avise cuando encuentre una multa nueva?")

      context = %{"action" => "confirm_subscribe", "plate" => plate} |> Poison.encode!
      Ecto.Changeset.change(sender, context: context) |> Repo.update!

    else
      context = %{"action" => "query_response_sent", "plate" => plate} |> Poison.encode!
      Ecto.Changeset.change(sender, context: context) |> Repo.update!
    end
  end

end
