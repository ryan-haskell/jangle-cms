module Shared exposing
    ( Flags, decoder
    , Model, Msg
    , init, update, subscriptions
    )

{-|

@docs Flags, decoder
@docs Model, Msg
@docs init, update, subscriptions

-}

import Effect exposing (Effect)
import Json.Decode
import Route exposing (Route)
import Route.Path
import Shared.Flags
import Shared.Model
import Shared.Msg



-- FLAGS


type alias Flags =
    Shared.Flags.Flags


decoder : Json.Decode.Decoder Flags
decoder =
    Shared.Flags.decoder



-- INIT


type alias Model =
    Shared.Model.Model


init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init flagsResult route =
    let
        flags : Flags
        flags =
            flagsResult
                |> Result.withDefault
                    { supabase = Nothing
                    }
    in
    ( { user =
            Just
                { name = "Ryan Haskell-Glatz"
                , email = "ryan.nhg@gmail.com"
                , image = Just "https://avatars.githubusercontent.com/u/6187256?v=4"
                }
                |> Debug.log "TODO: Remove this"
      }
    , Effect.none
    )



-- UPDATE


type alias Msg =
    Shared.Msg.Msg


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update route msg model =
    case msg of
        Shared.Msg.ExampleMsgReplaceMe ->
            ( model
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions route model =
    Sub.none
