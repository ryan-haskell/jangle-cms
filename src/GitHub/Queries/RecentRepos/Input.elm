module GitHub.Queries.RecentRepos.Input exposing
    ( Input, new
    , username
    , toInternalValue
    )

{-|

@docs Input, new

@docs username
@docs null

@docs toInternalValue

-}

import Dict exposing (Dict)
import GraphQL.Encode


type Input missing
    = Input (Dict String GraphQL.Encode.Value)


new : Input { missing | username : String }
new =
    Input Dict.empty


username :
    String
    -> Input { missing | username : String }
    -> Input missing
username value_ (Input dict_) =
    Input (Dict.insert "username" (GraphQL.Encode.string value_) dict_)


toInternalValue : Input {} -> List ( String, GraphQL.Encode.Value )
toInternalValue (Input dict_) =
    Dict.toList dict_
