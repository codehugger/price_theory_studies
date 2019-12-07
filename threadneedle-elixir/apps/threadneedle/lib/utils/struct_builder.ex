defmodule StructBuilder do
  defmacro __using__(_opts) do
    quote do
      @nested_maps Module.get_attribute(__MODULE__, :nested_maps, %{})
      @nested_lists Module.get_attribute(__MODULE__, :nested_lists, %{})

      @doc """
      Allow struct to be built from a map.

      ## Examples

          defmodule MyStruct do
             use StructBuilder
             defstruct ~w(a b)a
          end

          MyStruct.new(%{a: "a", b: "b"})
      """
      def new(fields \\ %{})

      def new(fields) when is_map(fields) do
        struct!(
          __MODULE__,
          fields
          |> Morphix.atomorphify!()
          |> transform_nested()
        )
        |> transform_parsed()
      end

      def new(fields) when is_bitstring(fields), do: Jason.decode!(fields) |> new()

      @doc """
      Allow struct to be built from a list.

      ## Examples

          defmodule MyStruct do
            use StructBuilder
            defstruct ~w(a b)a
          end

          # From Map
          MyStruct.new(%{a: "a", b: "b"})

          # From Keyword list
          MyStruct.new([a: "a", b: "b"])

          # From List
          MyStruct.new([:a, "a", :b, "b"])

          # From JSON string
          MyStruct.new(~s({"a": "a", "b": "b"}))
      """
      def new(fields) when is_list(fields) do
        case Keyword.keyword?(fields) do
          true -> fields |> Enum.into(%{})
          false -> fields |> Enum.chunk_every(2) |> Enum.map(fn [x, y] -> {x, y} end)
        end
        |> new()
      end

      #########################################################################
      # Private
      #########################################################################

      defp parse_map(fields, fun) do
        cond do
          is_map(fields) ->
            fields
            |> Enum.map(fn {k, v} -> {"#{k}", fun.(v)} end)
            |> Map.new()
            |> Morphix.stringmorphify!()

          is_list(fields) ->
            case Keyword.keyword?(fields) do
              true ->
                fields
                |> Enum.map(fn {x, y} -> {x, fun.(y)} end)
                |> Enum.into(%{})
                |> Morphix.stringmorphify!()

              false ->
                fields
                |> Enum.chunk_every(2)
                |> Enum.map(fn [x, y] -> {x, fun.(y)} end)
                |> Map.new()
                |> Morphix.stringmorphify!()
            end
        end
      end

      defp parse_list(fields, fun) do
        fields
        |> Enum.map(fn x -> fun.(x) end)
      end

      defp transform_nested(fields) do
        fields
        |> Enum.map(fn {k, v} ->
          cond do
            k in Map.keys(@nested_maps) -> {k, parse_map(v, @nested_maps[k])}
            k in Map.keys(@nested_lists) -> {k, parse_list(v, @nested_lists[k])}
            true -> {k, v}
          end
        end)
      end

      defp transform_parsed(struct) do
        struct
      end

      defoverridable(transform_nested: 1)
      defoverridable(transform_parsed: 1)
    end
  end
end
