defmodule EctoSearcher.Searcher.Field do
  @moduledoc nil

  require Ecto.Query
  alias Ecto.Query

  def lookup(field_name, mapping) do
    fields = mapping.fields

    if is_map(fields) && fields[field_name] do
      field = fields[field_name]

      case field do
        %{query: query} -> query
        anythong_else -> anythong_else
      end
    else
      default_field_query(field_name)
    end
  end

  defp default_field_query(field_name) do
    Query.dynamic([q], field(q, ^field_name))
  end
end
