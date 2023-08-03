module GitHub.Queries.RecentRepos exposing
    ( Input, new
    , Data
    , User, RepositoryConnection, Repository
    )

{-|

@docs Input, new

@docs Data
@docs User, RepositoryConnection, Repository

-}

import GitHub.Operation exposing (Operation)
import GitHub.Queries.RecentRepos.Input
import GraphQL.Decode
import GraphQL.Encode


type alias Data =
    { user : Maybe User
    }


type alias User =
    { repositories : RepositoryConnection
    }


type alias RepositoryConnection =
    { nodes : Maybe (List (Maybe Repository))
    }


type alias Repository =
    { databaseId : Maybe Int
    , nameWithOwner : String
    }


type alias Input =
    GitHub.Queries.RecentRepos.Input.Input {}


new : Input -> GitHub.Operation.Operation Data
new input =
    { name = "RecentRepos"
    , query = """
        query RecentRepos($username: String!) {
          user(login: $username) {
            repositories(
              first: 10
              affiliations: [OWNER]
              orderBy: { field: UPDATED_AT, direction: DESC }
            ) {
              nodes {
                databaseId
                nameWithOwner
              }
            }
          }
        }
      """
    , variables = GitHub.Queries.RecentRepos.Input.toInternalValue input
    , decoder = decoder
    }


decoder : GraphQL.Decode.Decoder Data
decoder =
    GraphQL.Decode.object Data
        |> GraphQL.Decode.field
            { name = "user"
            , decoder =
                GraphQL.Decode.object User
                    |> GraphQL.Decode.field
                        { name = "repositories"
                        , decoder =
                            GraphQL.Decode.object RepositoryConnection
                                |> GraphQL.Decode.field
                                    { name = "nodes"
                                    , decoder =
                                        GraphQL.Decode.object Repository
                                            |> GraphQL.Decode.field
                                                { name = "databaseId"
                                                , decoder = GraphQL.Decode.maybe GraphQL.Decode.int
                                                }
                                            |> GraphQL.Decode.field
                                                { name = "nameWithOwner"
                                                , decoder = GraphQL.Decode.string
                                                }
                                            |> GraphQL.Decode.maybe
                                            |> GraphQL.Decode.list
                                            |> GraphQL.Decode.maybe
                                    }
                        }
                    |> GraphQL.Decode.maybe
            }
