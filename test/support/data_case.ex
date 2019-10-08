defmodule Coophub.DataCase do
  @moduledoc """
  This module defines the setup for tests requiring
  access to the application's data layer.

  You may define functions here to be used as helpers in
  your tests.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias Coophub.Repos

      import Coophub.DataCase
    end
  end

  setup _tags do
    {:ok, []}
  end
end
