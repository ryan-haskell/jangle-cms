module GitHub.Mutations.UpdateFile exposing
    ( Input, new
    , Data
    , CreateCommitOnBranchPayload, Commit
    )

{-|

@docs Input, new

@docs Data
@docs CreateCommitOnBranchPayload, Commit

-}

import GitHub.Mutations.UpdateFile.Input
import GitHub.Scalars.Base64String
import GitHub.Scalars.GitObjectID
import GraphQL.Decode
import GraphQL.Encode
import GraphQL.Operation exposing (Operation)
import GraphQL.Scalar.Id



-- INPUT


type alias Input =
    GitHub.Mutations.UpdateFile.Input.Input {}


new : Input -> GraphQL.Operation.Operation Data
new input =
    { name = "UpdateFile"
    , query = """
        mutation UpdateFile(
          $branchId: ID!
          $expectedHeadOid: GitObjectID!
          $message: String!
          $path: String!
          $contents: Base64String!
        ) {
          createCommitOnBranch(input: {
            clientMutationId: "jangle-cms"
            branch: { id: $branchId }
            expectedHeadOid: $expectedHeadOid
            message: { headline: $message }
            fileChanges: {
              additions: [
                { path: $path, contents: $contents }
              ]
            }
          }) {
            commit { id }
          }
        }
      """
    , variables = GitHub.Mutations.UpdateFile.Input.toInternalValue input
    , decoder = decoder
    }



-- OUTPUT


type alias Data =
    { createCommitOnBranch : Maybe CreateCommitOnBranchPayload
    }


type alias CreateCommitOnBranchPayload =
    { commit : Maybe Commit
    }


type alias Commit =
    { id : GraphQL.Scalar.Id.Id
    }


decoder : GraphQL.Decode.Decoder Data
decoder =
    GraphQL.Decode.object Data
        |> GraphQL.Decode.field
            { name = "createCommitOnBranch"
            , decoder =
                GraphQL.Decode.object CreateCommitOnBranchPayload
                    |> GraphQL.Decode.field
                        { name = "commit"
                        , decoder =
                            GraphQL.Decode.object Commit
                                |> GraphQL.Decode.field
                                    { name = "id"
                                    , decoder = GraphQL.Decode.id
                                    }
                                |> GraphQL.Decode.maybe
                        }
                    |> GraphQL.Decode.maybe
            }
