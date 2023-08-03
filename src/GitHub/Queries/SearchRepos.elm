module GitHub.Queries.SearchRepos exposing
    ( Input, new
    , Data
    , SearchResultItemConnection, SearchResultItem
    )

{-|

@docs Input, new

@docs Data
@docs SearchResultItemConnection, SearchResultItem

-}

import GitHub.Operation exposing (Operation)
import GitHub.Queries.SearchRepos.Input
import GitHub.Queries.SearchRepos.SearchResultItem
import GraphQL.Decode
import GraphQL.Encode


type alias Data =
    { search : SearchResultItemConnection
    }


type alias SearchResultItemConnection =
    { nodes : Maybe (List (Maybe SearchResultItem))
    }


type alias SearchResultItem =
    GitHub.Queries.SearchRepos.SearchResultItem.SearchResultItem


type alias Input =
    GitHub.Queries.SearchRepos.Input.Input {}


new : Input -> GitHub.Operation.Operation Data
new input =
    { name = "SearchRepos"
    , query = """
        query SearchRepos($searchQuery: String!) {
          search(
            first: 10
            type: REPOSITORY
            query: $searchQuery
          ) {
            nodes {
              __typename
              ... on Repository {
                databaseId
                nameWithOwner
              }
            }
          }
        }
      """
    , variables = GitHub.Queries.SearchRepos.Input.toInternalValue input
    , decoder = decoder
    }


decoder : GraphQL.Decode.Decoder Data
decoder =
    GraphQL.Decode.object Data
        |> GraphQL.Decode.field
            { name = "search"
            , decoder =
                GraphQL.Decode.object SearchResultItemConnection
                    |> GraphQL.Decode.field
                        { name = "nodes"
                        , decoder =
                            GraphQL.Decode.union
                                [ GraphQL.Decode.variant
                                    { typename = "Repository"
                                    , onVariant = GitHub.Queries.SearchRepos.SearchResultItem.OnRepository
                                    , decoder =
                                        GraphQL.Decode.object GitHub.Queries.SearchRepos.SearchResultItem.Repository
                                            |> GraphQL.Decode.field
                                                { name = "databaseId"
                                                , decoder = GraphQL.Decode.maybe GraphQL.Decode.int
                                                }
                                            |> GraphQL.Decode.field
                                                { name = "nameWithOwner"
                                                , decoder = GraphQL.Decode.string
                                                }
                                    }
                                ]
                                |> GraphQL.Decode.maybe
                                |> GraphQL.Decode.list
                                |> GraphQL.Decode.maybe
                        }
            }
