module Supabase.Queries.FindProject.Input exposing
    ( Input, new
    , id
    , toInternalValue
    )

{-|

@docs Input, new

@docs id
@docs null

@docs toInternalValue

-}

import Dict exposing (Dict)
import GraphQL.Encode
import Supabase.Scalars.UUID


type Input missing
    = Input (Dict String GraphQL.Encode.Value)


new : Input { missing | id : Supabase.Scalars.UUID.UUID }
new =
    Input Dict.empty


id :
    Supabase.Scalars.UUID.UUID
    -> Input { missing | id : Supabase.Scalars.UUID.UUID }
    -> Input missing
id value_ (Input dict_) =
    Input (Dict.insert "id" (Supabase.Scalars.UUID.encode value_) dict_)


toInternalValue : Input {} -> List ( String, GraphQL.Encode.Value )
toInternalValue (Input dict_) =
    Dict.toList dict_
