module GitHub.Scalars.GitObjectID exposing
    ( GitObjectID
    , fromString, toString
    , decoder, encode
    )

{-|

@docs GitObjectID
@docs fromString, toString
@docs decoder, encode

-}

import GraphQL.Decode
import GraphQL.Encode
import Json.Decode


type GitObjectID
    = GitObjectID String


decoder : GraphQL.Decode.Decoder GitObjectID
decoder =
    GraphQL.Decode.scalar (Json.Decode.map GitObjectID Json.Decode.string)


encode : GitObjectID -> GraphQL.Encode.Value
encode (GitObjectID string) =
    GraphQL.Encode.string string


toString : GitObjectID -> String
toString (GitObjectID string) =
    string


fromString : String -> GitObjectID
fromString string =
    GitObjectID string
