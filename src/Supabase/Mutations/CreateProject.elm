module Supabase.Mutations.CreateProject exposing
    ( Input, new
    , Data
    , Project
    )

{-|

@docs Input, new

@docs Data
@docs Project

-}

import GraphQL.Decode
import GraphQL.Encode
import GraphQL.Operation exposing (Operation)
import Supabase.Mutations.CreateProject.Input
import Supabase.Scalars.UUID


type alias Data =
    { projects : ProjectsInsertResponse
    }


type alias ProjectsInsertResponse =
    { records : List Project
    }


type alias Project =
    { id : Supabase.Scalars.UUID.UUID
    }


type alias Input =
    Supabase.Mutations.CreateProject.Input.Input {}


new : Input -> GraphQL.Operation.Operation Data
new input =
    { name = "CreateProject"
    , query = """
        mutation CreateProject(
          $userId: UUID!,
          $title: String!,
          $githubRepoId: String!
        ) {
          projects: insertIntoprojectsCollection(objects: [
            { 
              title: $title
              user_id: $userId
              github_repo_id: $githubRepoId
            }
          ]) {
            records { ...Project }
          }
        }

        fragment Project on projects {
          id
        }
      """
    , variables = Supabase.Mutations.CreateProject.Input.toInternalValue input
    , decoder = decoder
    }


decoder : GraphQL.Decode.Decoder Data
decoder =
    GraphQL.Decode.object Data
        |> GraphQL.Decode.field
            { name = "projects"
            , decoder =
                GraphQL.Decode.object ProjectsInsertResponse
                    |> GraphQL.Decode.field
                        { name = "records"
                        , decoder =
                            GraphQL.Decode.object Project
                                |> GraphQL.Decode.field
                                    { name = "id"
                                    , decoder = Supabase.Scalars.UUID.decoder
                                    }
                                |> GraphQL.Decode.list
                        }
            }
