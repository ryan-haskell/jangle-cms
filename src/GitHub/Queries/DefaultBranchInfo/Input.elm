module GitHub.Queries.DefaultBranchInfo.Input exposing
    ( Input, new
    , owner, name
    , toInternalValue
    )

{-|

@docs Input, new

@docs owner, name
@docs null

@docs toInternalValue

-}

import Dict exposing (Dict)
import GraphQL.Encode


type Input missing
    = Input (Dict String GraphQL.Encode.Value)


new : Input { missing | owner : String, name : String }
new =
    Input Dict.empty


owner :
    String
    -> Input { missing | owner : String }
    -> Input missing
owner value_ (Input dict_) =
    Input (Dict.insert "owner" (GraphQL.Encode.string value_) dict_)


name :
    String
    -> Input { missing | name : String }
    -> Input missing
name value_ (Input dict_) =
    Input (Dict.insert "name" (GraphQL.Encode.string value_) dict_)


toInternalValue : Input {} -> List ( String, GraphQL.Encode.Value )
toInternalValue (Input dict_) =
    Dict.toList dict_
