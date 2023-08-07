module Supabase.Mutations.CreateProject.Input exposing
    ( Input, new
    , title, userId, githubRepoId
    , toInternalValue
    )

{-|

@docs Input, new

@docs title, userId, githubRepoId
@docs null

@docs toInternalValue

-}

import Dict exposing (Dict)
import GraphQL.Encode
import Supabase.Scalars.UUID


type Input missing
    = Input (Dict String GraphQL.Encode.Value)


new :
    Input
        { missing
            | title : String
            , userId : Supabase.Scalars.UUID.UUID
            , githubRepoId : String
        }
new =
    Input Dict.empty


title :
    String
    -> Input { missing | title : String }
    -> Input missing
title value_ (Input dict_) =
    Input (Dict.insert "title" (GraphQL.Encode.string value_) dict_)


userId :
    Supabase.Scalars.UUID.UUID
    -> Input { missing | userId : Supabase.Scalars.UUID.UUID }
    -> Input missing
userId value_ (Input dict_) =
    Input (Dict.insert "userId" (Supabase.Scalars.UUID.encode value_) dict_)


githubRepoId :
    String
    -> Input { missing | githubRepoId : String }
    -> Input missing
githubRepoId value_ (Input dict_) =
    Input (Dict.insert "githubRepoId" (GraphQL.Encode.string value_) dict_)


toInternalValue : Input {} -> List ( String, GraphQL.Encode.Value )
toInternalValue (Input dict_) =
    Dict.toList dict_
