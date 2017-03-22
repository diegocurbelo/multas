defmodule ImpoParser do
  use GenServer
  require Logger

  import Ecto.Query, only: [from: 2]

  alias Multas.{Repo, Publication, TrafficTicket, Notification}

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    Logger.info "Starting Publication parser..."
    reschedule()
    {:ok, state}
  end

  def handle_info(:work, state) do
    parse_publications()
    reschedule()
    {:noreply, state}
  end

  # --

  defp reschedule() do
    Process.send_after(self(), :work, 30 * 60 * 1000)
  end


  def parse_publications() do
    Logger.info "Parsing Publications..."
    Repo.all(from p in Publication, where: [processed: false], select: p)
    |> Enum.each(fn(p) ->
      Repo.delete_all(from t in TrafficTicket, where: [publication_id: ^p.id])
      case Fetch.get(p.url) do
        {:ok, html} ->
          process(p.id, p.date, html)
          Repo.update! Publication.changeset(p, %{processed: true})
          Logger.info "Successfully processed publication #{p.id} (#{p.url})"

        {:error, reason} ->
          Logger.error "Error processing publication #{p.id} (#{p.url}): #{inspect reason}"
      end
    end)
  end

  defp process(publication_id, publication_date, html) do
    html
    |> Floki.find("table.tabla_en_texto tr")
    |> Enum.drop(1)
    |> Enum.map(&parse_row(publication_id, publication_date, &1))
    |> Enum.each(&save_row/1)
  end

  defp parse_row(publication_id, publication_date, row) do
    values =
      row
      |> Floki.find("td pre")
      |> Enum.map(&extract/1)

    %{plate: Enum.at(values, 0),
      date: Enum.at(values, 1),
      location: Enum.at(values, 2),
      reason: Enum.at(values, 4),
      cost: Enum.at(values, 5),
      publication_id: publication_id,
      publication_date: publication_date}
  end

  # # fn({"pre", [], [text]}) -> text end
  defp extract({"pre", [], [text]}) do
    text
  end
  defp extract({"pre", [], text}) do
    ""
  end

  defp save_row(data) do
    case Repo.insert TrafficTicket.changeset(%TrafficTicket{}, data) do
      {:ok, struct} ->
        send_notification(struct)
        struct

      {:error, changeset} ->
        Logger.error "Error inserting Traffic Ticket: #{inspect changeset}"
    end
  end

  defp send_notification(ticket) do
    Repo.all(from n in Notification, where: [plate: ^ticket.plate, active: true], select: n)
    |> Enum.each(fn(n) ->
      Logger.info "Enviando notificacion a #{n.facebook_id} por la matrícula #{ticket.plate}"
      FacebookMessenger.send_message(n.facebook_id, "Nueva multa publicada para la matrícula #{ticket.plate} del día #{ticket.date} en #{ticket.location} por #{ticket.reason}.\nPuedes verificar las fotos en http://www.montevideo.gub.uy/consultainfracciones")
    end)
  end

end
