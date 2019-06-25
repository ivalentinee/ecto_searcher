defmodule EctoSearcher.Searcher.Utils.SearchQuery do
  @moduledoc """
  Builds SearchQuery from params

  This module is internal. Use at your own risk.
  """

  @enforce_keys [:field, :matcher, :value]
  defstruct [:field, :matcher, :value]

  @doc """
  Builds `%SearchQuery{}` from params

  ## Usage
  ```elixir
  searchable_fields = [:name, :description]
  search_params = %{"name_eq" => "Donald Trump", "description_cont" => "My president"}
  EctoSearcher.Searcher.SearchQuery.from_params(search_params, searchable_fields)
  # => [
  #      EctoSearcher.Searcher.SearchQuery(field: :name, matcher: "eq", value: "Donald Trump"),
  #      EctoSearcher.Searcher.SearchQuery(field: :description, matcher: "cont", value: "My president"),
  #    ]
  ```
  """
  def from_params(search_params, searchable_fields) do
    Enum.reduce(search_params, [], fn search_param, search_query_list ->
      case build(search_param, searchable_fields) do
        nil -> search_query_list
        search_query -> search_query_list ++ [search_query]
      end
    end)
  end

  @doc """
  Builds `%SearchQuery{}` from search expression.

  ## Usage
  ```elixir
  searchable_fields = [:name, :description]
  search_expression = {"name_eq", "Donald Trump"}
  EctoSearcher.Searcher.SearchQuery.build(search_expression, searchable_fields)
  # => EctoSearcher.Searcher.SearchQuery(field: :name, matcher: "eq", value: "Donald Trump")
  ```
  """
  def build(search_expression, searchable_fields)

  def build({search_key, value}, searchable_fields) do
    case field_and_matcher(search_key, searchable_fields) do
      {field, matcher} -> %__MODULE__{field: field, matcher: matcher, value: value}
      _ -> nil
    end
  end

  def build(_, _), do: nil

  defp field_and_matcher(search_key, searchable_fields) do
    field = search_field_name(search_key, searchable_fields)

    if field do
      split_into_field_and_matcher(search_key, field)
    end
  end

  defp search_field_name(search_key, searchable_fields) do
    Enum.find(searchable_fields, fn searchable_field ->
      String.starts_with?(search_key, "#{searchable_field}_")
    end)
  end

  defp split_into_field_and_matcher(search_key, field) do
    matcher_name = String.replace_leading(search_key, "#{field}_", "")
    {field, matcher_name}
  end
end
