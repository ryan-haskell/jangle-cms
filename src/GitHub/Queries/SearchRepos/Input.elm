module GitHub.Queries.SearchRepos.Input exposing
    ( Input, new
    , searchQuery
    , toInternalValue
    )

{-|

@docs Input, new

@docs searchQuery
@docs null

@docs toInternalValue

-}

import Dict exposing (Dict)
import GraphQL.Encode


type Input missing
    = Input (Dict String GraphQL.Encode.Value)


new : Input { missing | searchQuery : String }
new =
    Input Dict.empty


searchQuery :
    String
    -> Input { missing | searchQuery : String }
    -> Input missing
searchQuery value_ (Input dict_) =
    Input (Dict.insert "searchQuery" (GraphQL.Encode.string value_) dict_)


toInternalValue : Input {} -> List ( String, GraphQL.Encode.Value )
toInternalValue (Input dict_) =
    Dict.toList dict_
