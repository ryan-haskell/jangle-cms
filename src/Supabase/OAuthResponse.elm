module Supabase.OAuthResponse exposing
    ( OAuthResponse
    , fromUrlFragment
    , encode, decoder
    )

{-|

@docs OAuthResponse
@docs fromUrlFragment
@docs encode, decoder

-}

import Dict exposing (Dict)
import Json.Decode
import Json.Encode


type alias OAuthResponse =
    { accessToken : String
    , providerToken : String
    , expiresInSeconds : Maybe Int
    , refreshToken : String
    , tokenType : TokenType
    }


type TokenType
    = Bearer


encode : OAuthResponse -> Json.Encode.Value
encode res =
    Json.Encode.object
        [ ( "access_token", Json.Encode.string res.accessToken )
        , ( "provider_token", Json.Encode.string res.providerToken )
        , ( "expires_in"
          , res.expiresInSeconds |> Maybe.map Json.Encode.int |> Maybe.withDefault Json.Encode.null
          )
        , ( "refresh_token", Json.Encode.string res.refreshToken )
        , ( "token_type", Json.Encode.string "bearer" )
        ]


decoder : Json.Decode.Decoder OAuthResponse
decoder =
    Json.Decode.map5 OAuthResponse
        (Json.Decode.field "access_token" Json.Decode.string)
        (Json.Decode.field "provider_token" Json.Decode.string)
        (Json.Decode.field "expires_in" (Json.Decode.maybe Json.Decode.int))
        (Json.Decode.field "refresh_token" Json.Decode.string)
        (Json.Decode.field "token_type" (Json.Decode.succeed Bearer))


{-| When Supabase responds from a successful OAuth sign in, it will redirect to your app with
`"access_token=..."` in the URL's hash fragment. This function converts that string into nicely
structured data to use in your application.
-}
fromUrlFragment : Maybe String -> Maybe OAuthResponse
fromUrlFragment maybeFragment =
    let
        dict : Dict String String
        dict =
            case maybeFragment of
                Just str ->
                    str
                        |> String.split "&"
                        |> List.map (String.split "=")
                        |> List.filterMap
                            (\list ->
                                Maybe.map2 Tuple.pair
                                    (List.head list)
                                    (List.drop 1 list |> List.head)
                            )
                        |> Dict.fromList

                Nothing ->
                    Dict.empty
    in
    Maybe.map5 OAuthResponse
        (Dict.get "access_token" dict)
        (Dict.get "provider_token" dict)
        (Dict.get "expires_in" dict
            |> Maybe.map String.toInt
        )
        (Dict.get "refresh_token" dict)
        (Dict.get "token_type" dict
            |> Maybe.andThen
                (\str ->
                    case str of
                        "bearer" ->
                            Just Bearer

                        _ ->
                            Nothing
                )
        )
