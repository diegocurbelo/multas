defmodule Multas.Plugs.SignatureParser do
  @behaviour Plug.Parsers
  import Plug.Conn

  def parse(conn, "application", _subtype, _headers, _opts) do
    if is_binary(get_req_header(conn, "x-hub-signature")) do
      with {:ok, body, _} <- Plug.Conn.read_body(conn), do:
        conn = put_private(conn, :raw_body, body)
    end
    {:next, conn}
  end

  def parse(conn, _, _, _, _), do: {:next, conn}

end
