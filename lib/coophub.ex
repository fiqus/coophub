defmodule Coophub do
  @moduledoc """
  Coophub keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  # @TODO Move this function to where it should be and DON'T make it recursive (just the root level keys for the structs are enough)
  @spec map_string_to_atom_keys(any) :: map
  def map_string_to_atom_keys(map) when is_map(map) do
    for {k, v} <- map, into: %{}, do: {String.to_atom(k), map_string_to_atom_keys(v)}
  end

  def map_string_to_atom_keys(value), do: value
end
