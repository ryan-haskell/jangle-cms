module GitHub.Operation exposing (Operation)

import GraphQL.Decode
import GraphQL.Encode


type alias Operation value =
    { name : String
    , query : String
    , variables : List ( String, GraphQL.Encode.Value )
    , decoder : GraphQL.Decode.Decoder value
    }
