module GitHub.Scalars.Base64String exposing
    ( Base64String
    , fromString, toString
    , decoder, encode
    )

{-|

@docs Base64String
@docs fromString, toString
@docs decoder, encode

-}

import Base64
import GraphQL.Decode
import GraphQL.Encode
import Json.Decode


type Base64String
    = Base64String String


decoder : GraphQL.Decode.Decoder Base64String
decoder =
    GraphQL.Decode.scalar (Json.Decode.map Base64String Json.Decode.string)


encode : Base64String -> GraphQL.Encode.Value
encode (Base64String string) =
    GraphQL.Encode.string string


toString : Base64String -> String
toString (Base64String encoded) =
    case Base64.decode encoded of
        Ok string ->
            string

        Err _ ->
            encoded


fromString : String -> Base64String
fromString string =
    Base64String (Base64.encode string)
