defmodule Coophub.Backends.GitlabCom do
  use Coophub.Backends.Gitlab

  @spec name() :: String.t()
  def name(), do: "gitlab.com"

  def headers() do
    []
  end

  def full_url(path), do: "https://gitlab.com/api/v4/#{path}"
end
