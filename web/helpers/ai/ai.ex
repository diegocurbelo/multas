defmodule Multas.Helpers.AI do
  require Logger

  alias Multas.{Repo}

  @regex_plate_ABC1234  ~r/\b([A-Z])\W*([A-Z])\W*([A-Z])\W*(\d)\W*(\d)\W*(\d)\W*(\d)\W*\b/
  @regex_plate_ABC123   ~r/\b([A-Z])\W*([A-Z])\W*([A-Z])\W*(\d)\W*(\d)\W*(\d)\W*\b/
  @regex_plate_B123456  ~r/\b(B)\W*(\d)\W*(\d)\W*(\d)\W*(\d)\W*(\d)\W*(\d)\W*\b/
  @regex_plate_B12345   ~r/\b(B)\W*(\d)\W*(\d)\W*(\d)\W*(\d)\W*(\d)\W*\b/
  @regex_plate_B1234    ~r/\b(B)\W*(\d)\W*(\d)\W*(\d)\W*(\d)\W*\b/
  @regex_plate_123ABC   ~r/\b(\d)\W*(\d)\W*(\d)\W*([A-Z])\W*([A-Z])\W*([A-Z])\W*\b/
  @regex_plate_AB123CD  ~r/\b([A-Z])\W*([A-Z])\W*(\d)\W*(\d)\W*(\d)\W*([A-Z])\W*([A-Z])\W*\b/


  def parse_intent(sender, text) do
    text = String.upcase text
    context = Poison.decode! sender.context

    case context do
      %{"action" => "confirm_subscribe", "plate" => plate} ->
        cond do
          String.contains?(text, ["SI", "SÍ", "OK", "CLARO", "OBVIO"]) -> {:subscribe, plate}
          String.contains?(text, ["NO", "NEGATIVO", "NUNCA"]) -> {:thanks}
          true -> parse_intent_without_context(sender, text)
        end

      # %{"action" => "confirm_subscribe", "plate" => plate} ->
      # %{"action" => "query_response_sent", "plate" => plate} ->
      # %{"action" => "subscription_confirmed", "plate" => plate} ->
      # %{"action" => "subscription_rejected", "plate" => plate} ->
      # %{"action" => "query_response_sent"} ->

      _ ->
        parse_intent_without_context(sender, text)
    end
  end


  # --


  defp parse_intent_without_context(sender, text) do
    Ecto.Changeset.change(sender, context: "{}") |> Repo.update!

    plate = extract_plate(text)

    cond do
      String.contains?(text, "NO") and String.contains?(text, "NOTIFIQUES") and plate ->
        {:unsubscribe, plate}

      string_similar?(text, ["GRACIAS", "EXCELENTE", "GENIAL", "OK", "IMPECABLE", "LUJO"]) ->
        {:thanks}

      true ->
        if plate do
          {:query, plate}
        else
          {:unknown}
        end
    end
  end


  defp extract_plate(text) do
    regex_parsers = [@regex_plate_ABC1234, @regex_plate_ABC123, @regex_plate_B123456,
                     @regex_plate_B12345, @regex_plate_B1234, @regex_plate_123ABC, @regex_plate_AB123CD]
    extract_plate(text, regex_parsers)
  end

  defp extract_plate(text, [regex | other_parsers]) do
    result = Regex.run(regex, text, capture: :all_but_first)
    if result do
      case regex do
        @regex_plate_ABC1234 ->
          [a1, a2, a3, n1, n2, n3, n4] = result
          "#{a1}#{a2}#{a3} #{n1}#{n2}#{n3}#{n4}"
        @regex_plate_ABC123  ->
          [a1, a2, a3, n1, n2, n3] = result
          "#{a1}#{a2}#{a3} #{n1}#{n2}#{n3}"
        @regex_plate_B123456 ->
          [a1, n1, n2, n3, n4, n5, n6] = result
          "#{a1} #{n1}#{n2}#{n3}#{n4}#{n5}#{n6}"
        @regex_plate_B12345  ->
          [a1, n1, n2, n3, n4, n5] = result
          "#{a1} #{n1}#{n2}#{n3}#{n4}#{n5}"
        @regex_plate_B1234   ->
          [a1, n1, n2, n3, n4] = result
          "#{a1} #{n1}#{n2}#{n3}#{n4}"
        @regex_plate_123ABC  ->
          [n1, n2, n3, a1, a2, a3] = result
          "#{n1}#{n2}#{n3} #{a1}#{a2}#{a3}"
        @regex_plate_AB123CD ->
          [a1, a2, n1, n2, n3, a3, a4] = result
          "#{a1}#{a2} #{n1}#{n2}#{n3} #{a3}#{a4}"
      end
    else
      extract_plate(text, other_parsers)
    end
  end

  defp extract_plate(text, _) do
    nil
  end

  defp string_similar?(text, [phrase | other_phrases]) do
    if String.jaro_distance(text, phrase) > 0.8 do
      true
    else
      string_similar?(text, other_phrases)
    end
  end

  defp string_similar?(text, _) do
    false
  end
end
