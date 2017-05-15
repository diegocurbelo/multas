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
        "AV8DEOCTUBREYGRALGARIBALDI"   -> "Av. 8 de Octubre y Garibaldi"
        "AVITALIAYBOLONIA"             -> "Av. Italia y Bolonia"
        "AVITALIAYFRANCISCOSIMON"      -> "Av. Italia y Fransico Simón"
        "AVITALIAYLIDO"                -> "Av. Italia y Lido"
        "AVITALIAYMATAOJO"             -> "Av. Italia y Mataojo"
        "AVMILLANYCISPLATINA"          -> "Av. Millán y Cisplatina"
        "AVRIVERAYAVLUISPONCE"         -> "Av. Rivera y Av. Luis Ponce"
        "AVRIVERAYFCOLLAMBI"           -> "Av. Rivera y Francisco Llambi"
        "AVRIVERAYMARIAESPINOLA"       -> "Av. Rivera y Maria Espinola"
        "BVARTIGASY21DESETIEMBRE"      -> "Bv. Artigas y 21 de Setiembre"
        "BVARTIGASYCAMPISTEGUY"        -> "Bv. Artigas y Campisteguy"
        "BVARTIGASYPEDERNAL"           -> "Bv. Artigas y Pedernal"
        "BRBYORDONEZYAV8DEOCTUBRE"     -> "Bv. Batlle y Ordóñez y Av. 8 de Octubre"
        "AVGRALFLORESYDARAMBURU"       -> "Gral. Flores y D. Aramburú"
        "LADEHERRERAYAVRIVERA"         -> "L. A. de Herrera y Av. Rivera"
        "RAMBLAMGANDHIYSOLANOGARCIA"   -> "Rambla Gandhi y Solano García"
        "RAMBLAOHIGGINSY18DEDICIEMBRE" -> "Rambla O'Higgins y 18 de Diciembre"
        "RAMBLAOHIGGINSYMDEPROTEO"     -> "Rambla O'Higgins y Motivos de Proteo"
        "RREPARGENTINAYCARLOSMMORALES" -> "Rambla Rep. Argentina y Carlos M. Morales"
        "RREPARGENTINAYEDUARDOACEVEDO" -> "Rambla Rep. Argentina y Eduardo Acevedo"
        "RREPDEMEXICOYCOSTARICA"       -> "Rambla Rep. de México y Costa Rica"
        "RREPDELPERUYLADEHERRERA"      -> "Rambla Rep. del Perú y L. A. de Herrera"
        _ ->
          Logger.error "Unexpected Traffic Ticket location: #{text}"
          text
    end
  end

  defp normalize_reason(text) do
    text
    |> normalize_plate
    |> case do
        "ART11032EXCESODEVELOCIDAD"     -> "Exceso de velocidad"
        "ART1106CRUZAROGIRARCONLUZROJA" -> "Cruzar o girar con luz roja"
        _ ->
          Logger.error "Unexpected Traffic Ticket reason: #{text}"
          text
    end
  end

end
