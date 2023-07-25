module Storybook.Controls exposing
    ( Decoder, new
    , withText, withBoolean, withSelect
    , decodeValue
    )

{-|

@docs Decoder, new
@docs withText, withBoolean, withSelect

@docs decodeValue

-}

import Json.Decode


type Decoder value
    = Decoder (Json.Decode.Decoder value)


new : value -> Decoder value
new value =
    Decoder (Json.Decode.succeed value)


withText : { id : String } -> Decoder (String -> value) -> Decoder value
withText options (Decoder fnDecoder) =
    Decoder
        (Json.Decode.map2 (<|)
            fnDecoder
            (Json.Decode.oneOf
                [ Json.Decode.field options.id Json.Decode.string
                , Json.Decode.succeed ""
                ]
            )
        )


withSelect :
    { id : String
    , options : List ( String, option )
    }
    -> Decoder (Maybe option -> value)
    -> Decoder value
withSelect options (Decoder fnDecoder) =
    let
        findOption : String -> Maybe option
        findOption str =
            options.options
                |> List.filterMap
                    (\( key, value ) ->
                        if key == str then
                            Just value

                        else
                            Nothing
                    )
                |> List.head
    in
    Decoder
        (Json.Decode.map2 (<|)
            fnDecoder
            (Json.Decode.oneOf
                [ Json.Decode.field options.id Json.Decode.string
                    |> Json.Decode.map findOption
                , Json.Decode.succeed Nothing
                ]
            )
        )


withBoolean : { id : String } -> Decoder (Bool -> value) -> Decoder value
withBoolean options (Decoder fnDecoder) =
    Decoder
        (Json.Decode.map2 (<|)
            fnDecoder
            (Json.Decode.oneOf
                [ Json.Decode.field options.id Json.Decode.bool
                , Json.Decode.succeed False
                ]
            )
        )


decodeValue : Json.Decode.Value -> Decoder value -> Maybe value
decodeValue json (Decoder decoder) =
    case Json.Decode.decodeValue decoder json of
        Ok value ->
            Just value

        Err _ ->
            Nothing
