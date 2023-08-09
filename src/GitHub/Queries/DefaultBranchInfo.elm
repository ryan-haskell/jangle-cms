module GitHub.Queries.DefaultBranchInfo exposing
    ( Input, new
    , Data
    , Repository, Ref, GitObject
    )

{-|

@docs Input, new

@docs Data
@docs Repository, Ref, GitObject

-}

import GitHub.Queries.DefaultBranchInfo.Input
import GitHub.Scalars.GitObjectID
import GraphQL.Decode
import GraphQL.Encode
import GraphQL.Operation exposing (Operation)
import GraphQL.Scalar.Id



-- INPUT


type alias Input =
    GitHub.Queries.DefaultBranchInfo.Input.Input {}


new : Input -> GraphQL.Operation.Operation Data
new input =
    { name = "DefaultBranchInfo"
    , query = """
        query DefaultBranchInfo($owner: String!, $name: String!) {
          repository(name: $name, owner: $owner) {
            defaultBranchRef {
              id
              target {
                oid
              }
            }
          }
        }
      """
    , variables = GitHub.Queries.DefaultBranchInfo.Input.toInternalValue input
    , decoder = decoder
    }



-- OUTPUT


type alias Data =
    { repository : Maybe Repository
    }


type alias Repository =
    { defaultBranchRef : Maybe Ref
    }


type alias Ref =
    { id : GraphQL.Scalar.Id.Id
    , target : Maybe GitObject
    }


type alias GitObject =
    { oid : GitHub.Scalars.GitObjectID.GitObjectID
    }


decoder : GraphQL.Decode.Decoder Data
decoder =
    GraphQL.Decode.object Data
        |> GraphQL.Decode.field
            { name = "repository"
            , decoder =
                GraphQL.Decode.object Repository
                    |> GraphQL.Decode.field
                        { name = "defaultBranchRef"
                        , decoder =
                            GraphQL.Decode.object Ref
                                |> GraphQL.Decode.field
                                    { name = "id"
                                    , decoder = GraphQL.Decode.id
                                    }
                                |> GraphQL.Decode.field
                                    { name = "target"
                                    , decoder =
                                        GraphQL.Decode.object GitObject
                                            |> GraphQL.Decode.field
                                                { name = "oid"
                                                , decoder = GitHub.Scalars.GitObjectID.decoder
                                                }
                                            |> GraphQL.Decode.maybe
                                    }
                                |> GraphQL.Decode.maybe
                        }
                    |> GraphQL.Decode.maybe
            }
