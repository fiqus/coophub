defmodule Coophub.Backends.GitCoop do
  use Coophub.Backends.Gitlab

  @spec name() :: String.t()
  def name(), do: "git.coop"

  def headers() do
    []
  end

  def full_url(path), do: "https://git.coop/api/v4/#{path}"
end
