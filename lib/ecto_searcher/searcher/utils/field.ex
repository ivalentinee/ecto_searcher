defmodule EctoSearcher.Searcher.Utils.Field do
  @moduledoc false

  require Ecto.Query
  alias Ecto.Query

  def lookup(field_name, schema, mapping) do
    cond do
      custom_field?(field_name, mapping) -> custom_field_query(field_name, mapping)
      schema_field?(field_name, schema) -> schema_field_query(field_name)
      true -> nil
    end
  end

  defp custom_field?(field, mapping) do
    Map.has_key?(mapping.fields, field)
  end

  defp schema_field?(field, schema) do
    Enum.member?(schema.__schema__(:fields), field)
  end

  defp custom_field_query(field_name, mapping) do
    mapping_entry = mapping.fields[field_name]
    mapping_entry[:query]
  end

  defp schema_field_query(field_name) do
    Query.dynamic([q], field(q, ^field_name))
  end
end
