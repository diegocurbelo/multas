defmodule Multas.TrafficTicket do
  use Multas.Web, :model

  require Logger

  schema "traffic_tickets" do
    field :plate, :string
    field :date, :string
    field :location, :string
    field :reason, :string
    field :cost, :string
    field :publication_id, :integer
    field :publication_date, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:plate, :date, :location, :reason, :cost, :publication_id, :publication_date])
    |> validate_required([:plate, :publication_date, :publication_id])
    |> update_change(:plate, &normalize_plate/1)
    |> update_change(:location, &normalize_location/1)
    |> update_change(:reason, &normalize_reason/1)
  end

  # --

  defp normalize_plate(text) do
    text
    |> String.replace(~r/\W*/u, "")
    |> String.upcase
  end

  defp normalize_location(text) do
    text
    |> normalize_plate
    |> case do
        "RAMBLAOHIGGINSY18DEDICIEMBRE" -> "Rambla O'Higgins y 18 de Diciembre"
        "RAMBLAMGANDHIYSOLANOGARCIA"   -> "Rambla Gandhi y Solano García"
        "RREPDELPERUYLADEHERRERA"      -> "Rambla Rep. del Perú y L. A. de Herrera"
        "RREPDEMEXICOYCOSTARICA"       -> "Rambla Rep. de México y Costa Rica"
        "RREPARGENTINAYCARLOSMMORALES" -> "Rambla Rep. Argentina y Carlos M. Morales"
        "RREPARGENTINAYEDUARDOACEVEDO" -> "Rambla Rep. Argentina y Eduardo Acevedo"
        "LADEHERRERAYAVRIVERA"         -> "L. A. de Herrera y Av. Rivera"
        "BVARTIGASYPEDERNAL"           -> "Bv. Artigas y Pedernal"
        "BVARTIGASYCAMPISTEGUY"        -> "Bv. Artigas y Campisteguy"
        "BVARTIGASY21DESETIEMBRE"      -> "Bv. Artigas y 21 de Setiembre"
        "AVGRALFLORESYDARAMBURU"       -> "Gral. Flores y D. Aramburú"
        "AVRIVERAYMARIAESPINOLA"       -> "Av. Rivera y Maria Espinola"
        "AVRIVERAYAVLUISPONCE"         -> "Av. Rivera y Av. Luis Ponce"
        "AVRIVERAYFCOLLAMBI"           -> "Av. Rivera y Francisco Llambi"
        "AVITALIAYMATAOJO"             -> "Av. Italia y Mataojo"
        "AVITALIAYLIDO"                -> "Av. Italia y Lido"
        "AVITALIAYFRANCISCOSIMON"      -> "Av. Italia y Fransico Simón"
        "AVITALIAYBOLONIA"             -> "Av. Italia y Bolonia"
        "AVMILLANYCISPLATINA"          -> "Av. Millán y Cisplatina"
        _ ->
          Logger.error "Unexpected Traffic Ticket location: #{text}"
          text
    end
  end

  defp normalize_reason(text) do
    text
    |> String.upcase
    |> case do
        "ART. 1/103/2: EXCESO DE VELOCIDAD"       -> "Exceso de velocidad"
        "ART. 1/106: CRUZAR O GIRAR CON LUZ ROJA" -> "Cruzar o girar con luz roja"
        _ ->
          Logger.error "Unexpected Traffic Ticket reason: #{text}"
          text
    end
  end

end
