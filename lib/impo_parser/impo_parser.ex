defmodule ImpoParser do
  use GenServer
  use Timex

  require Logger

  import Ecto.Query, only: [from: 2]

  alias Multas.{Repo, Publication, TrafficTicket, Notification,Helpers.AI}

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    Logger.info "Starting Publication parser..."
    reschedule()
    {:ok, state}
  end

  def handle_info(:work, state) do
    Logger.info "[IMPO Parser] Checking for new publications..."
    check_for_new_publications()
    Logger.info "[IMPO Parser] Parsing publications..."
    parse_publications()
    Logger.info "[IMPO Parser] Completed."
    reschedule()
    {:noreply, state}
  end

  # --

  defp check_for_new_publications() do
    last_publication = Repo.one! from p in Publication, order_by: [desc: p.id], limit: 1
    next_number = String.to_integer(last_publication.name) + 1
    next_url = "http://www.impo.com.uy/bases/notificaciones-cgm/#{next_number}-2017"

    Logger.info "[IMPO Parser] >> Checking if publication #{next_number} exists..."

    case Fetch.get(next_url) do
      {:ok, html} ->
        tickets = html |> Floki.find("table.tabla_en_texto tr")

        if length(tickets) > 0 do
          publication =
            %{name: Integer.to_string(next_number),
              date: Timex.format!(Timex.now, "%Y-%m-%d", :strftime),
              url: next_url}

          case Repo.insert Publication.changeset(%Publication{}, publication) do
            {:ok, struct} ->
              check_for_new_publications()
            {:error, changeset} ->
              Logger.error "[IMPO Parser] >> Error inserting Publication: #{inspect changeset}"
          end
        end

      {:error, reason} ->
        Logger.error "[IMPO Parser] >> Error check_for_new_publications after #{next_url}: #{inspect reason}"
    end
  end

  def parse_publications() do
    Repo.all(from p in Publication, where: [processed: false], select: p)
    |> Enum.each(fn(p) ->
      Repo.delete_all(from t in TrafficTicket, where: [publication_id: ^p.id])
      case Fetch.get(p.url) do
        {:ok, html} ->
          process(p.id, p.date, html)
          Repo.update! Publication.changeset(p, %{processed: true})
          Logger.info "[IMPO Parser] >> Successfully parsed publication #{p.id} (#{p.url})"

          query = from TrafficTicket, where: [publication_id: ^p.id]
          count = Repo.aggregate(query, :count, :id)
          FacebookMessenger.send_message("1291833860863602", "Ya están cargadas las #{count} multas publicadas este #{pretty_date(Timex.now)}")

        {:error, reason} ->
          Logger.error "[IMPO Parser] >> Error processing publication #{p.id} (#{p.url}): #{inspect reason}"
      end
    end)
  end

  defp reschedule() do
    Process.send_after(self(), :work, 30 * 60 * 1000)
  end

  #--

  defp process(publication_id, publication_date, html) do
    html
    |> Floki.find("table.tabla_en_texto tr")
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

  defp extract({"pre", [], [text]}) do
    text
  end
  defp extract({"pre", [], text}) do
    ""
  end

  defp save_row(data) do
    if String.valid?(data.plate) && AI.extract_plate(data.plate) do
      case Repo.insert TrafficTicket.changeset(%TrafficTicket{}, data) do
        {:ok, struct} ->
          send_notification(struct)
          struct
        {:error, changeset} ->
          Logger.error "[IMPO Parser] >> Error inserting Traffic Ticket: #{inspect changeset}"
      end
    else
      Logger.warn "[IMPO Parser] >> Ignoring Traffic Ticket: Invalid plate in: #{inspect data}"
    end
  end

  defp send_notification(ticket) do
    Repo.all(from n in Notification, where: [plate: ^ticket.plate, active: true], select: n)
    |> Enum.each(fn(n) ->
      Logger.info "[IMPO Parser] >> Enviando notificacion a #{n.facebook_id} por la matrícula #{ticket.plate}"
      FacebookMessenger.send_message(n.facebook_id, "Nueva multa publicada para la matrícula #{ticket.plate} del día #{ticket.date} en #{ticket.location} por #{ticket.reason}.\nPuedes verificar las fotos en http://www.montevideo.gub.uy/consultainfracciones")
    end)
  end

  defp pretty_date(date) do
    [day, number, month] =
      Timex.format!(date, "%u %d %m", :strftime)
      |> String.split

    day_name =
      case String.to_integer(day) do
        1 -> "lunes"
        2 -> "martes"
        3 -> "miercoles"
        4 -> "jueves"
        5 -> "viernes"
        6 -> "sabado"
        7 -> "domingo"
      end

    month_name =
      case String.to_integer(month) do
        1  -> "enero"
        2  -> "febrero"
        3  -> "marzo"
        4  -> "abril"
        5  -> "mayo"
        6  -> "junio"
        7  -> "julio"
        8  -> "agosto"
        9  -> "septiembre"
        10 -> "octubre"
        11 -> "noviembre"
        12 -> "diciembre"
      end

    "#{day_name} #{number} de #{month_name}"
  end
end
