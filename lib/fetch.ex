defmodule Fetch do
  @opts [
    follow_redirect: true,
    timeout: 33_000,
    recv_timeout: 30_000
  ]

  def get(url) do
    HTTPoison.get(url, [], @opts)
    |> evaluate
  end

  # --

  defp evaluate({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    {:ok, body}
  end
  defp evaluate({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end
  defp evaluate(_) do
    {:error, :unknown_fetch_error}
  end
end
