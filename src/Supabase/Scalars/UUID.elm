module Supabase.Scalars.UUID exposing
    ( UUID
    , fromString, toString
    , decoder, encode
    )

{-|

@docs UUID
@docs fromString, toString
@docs decoder, encode

-}

import GraphQL.Decode
import GraphQL.Encode
import Json.Decode


type UUID
    = UUID String


decoder : GraphQL.Decode.Decoder UUID
decoder =
    GraphQL.Decode.scalar (Json.Decode.map UUID Json.Decode.string)


encode : UUID -> GraphQL.Encode.Value
encode (UUID string) =
    GraphQL.Encode.string string


toString : UUID -> String
toString (UUID string) =
    string


fromString : String -> UUID
fromString string =
    UUID string
