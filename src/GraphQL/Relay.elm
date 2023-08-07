module GraphQL.Relay exposing (toNodes)


toNodes : { connection | nodes : Maybe (List (Maybe node)) } -> List node
toNodes connection =
    connection.nodes
        |> Maybe.withDefault []
        |> List.filterMap identity
