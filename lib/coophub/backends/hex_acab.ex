defmodule Coophub.Backends.HexAcab do
  use Coophub.Backends.Gitlab

  @spec name() :: String.t()
  def name(), do: "0xacab.org"

  def headers() do
    []
  end

  def full_url(path), do: "https://0xacab.org/api/v4/#{path}"
end
