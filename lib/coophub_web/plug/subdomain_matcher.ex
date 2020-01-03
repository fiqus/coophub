defmodule CoophubWeb.Plug.SubdomainMatcher do
  @behaviour Plug
  import Plug.Conn, only: [put_private: 3, halt: 1]
  import Phoenix.Controller, only: [redirect: 2]

  @spec init(Keyword.t()) :: Keyword.t()
  def init(_opts) do
    Application.get_env(:coophub, CoophubWeb.Endpoint)[:url][:host]
  end

  @spec call(Plug.Conn.t(), Keyword.t()) :: Plug.Conn.t()
  def call(%Plug.Conn{host: host} = conn, root_host) do
    case extract_subdomain(host, root_host) do
      nil ->
        conn

      subdomain ->
        conn
        |> put_private(:subdomain, subdomain)
        |> redirect_subdomain(root_host, subdomain)
    end
  end

  defp extract_subdomain(host, root_host) do
    case Regex.run(~r/(.+)\.#{root_host}/, host) do
      [_, subdomain] when byte_size(subdomain) > 0 -> subdomain
      _ -> nil
    end
  end

  defp redirect_subdomain(conn, host, subdomain) do
    base_url = "#{conn.scheme}://#{host}:#{conn.port}"

    path =
      if Coophub.Repos.org_exists?(subdomain) do
        "orgs"
      else
        "languages"
      end

    conn
    |> redirect(external: "#{base_url}/#{path}/#{subdomain}")
    |> halt()
  end
end
