module Supabase.Queries.MyProjects exposing
    ( Data, new
    , ProjectsConnection, ProjectsEdge, Project
    )

{-|

@docs Data, new
@docs ProjectsConnection, ProjectsEdge, Project

-}

import GraphQL.Decode
import GraphQL.Encode
import GraphQL.Operation exposing (Operation)
import Supabase.Scalars.UUID


type alias Data =
    { projects : Maybe ProjectsConnection
    }


type alias ProjectsConnection =
    { edges : List ProjectsEdge
    }


type alias ProjectsEdge =
    { node : Project
    }


type alias Project =
    { id : Supabase.Scalars.UUID.UUID
    , title : String
    , github_repo_id : String
    }


new : GraphQL.Operation.Operation Data
new =
    { name = "MyProjects"
    , query = """
        query MyProjects {
          projects: projectsCollection(first: 25) {
            edges {
              node {
                ...Project
              }
            }
          }
        }

        fragment Project on projects {
          id
          title
          github_repo_id
        }
      """
    , variables = []
    , decoder = decoder
    }


decoder : GraphQL.Decode.Decoder Data
decoder =
    GraphQL.Decode.object Data
        |> GraphQL.Decode.field
            { name = "projects"
            , decoder =
                GraphQL.Decode.object ProjectsConnection
                    |> GraphQL.Decode.field
                        { name = "edges"
                        , decoder =
                            GraphQL.Decode.object ProjectsEdge
                                |> GraphQL.Decode.field
                                    { name = "node"
                                    , decoder =
                                        GraphQL.Decode.object Project
                                            |> GraphQL.Decode.field
                                                { name = "id"
                                                , decoder = Supabase.Scalars.UUID.decoder
                                                }
                                            |> GraphQL.Decode.field
                                                { name = "title"
                                                , decoder = GraphQL.Decode.string
                                                }
                                            |> GraphQL.Decode.field
                                                { name = "github_repo_id"
                                                , decoder = GraphQL.Decode.string
                                                }
                                    }
                                |> GraphQL.Decode.list
                        }
                    |> GraphQL.Decode.maybe
            }
