module Tests.Page exposing
    ( toProgramTest, toAuthenticatedProgramTest
    , sendMsg
    )

{-|

@docs toProgramTest, toAuthenticatedProgramTest

@docs sendMsg

-}

import Auth
import Effect exposing (Effect)
import Json.Decode
import Json.Encode
import Page exposing (Page)
import ProgramTest exposing (ProgramTest)
import Route exposing (Route)
import Shared
import Shared.Flags
import SimulatedEffect.Cmd
import Supabase.Scalars.UUID
import Url exposing (Url)


user : Auth.User
user =
    { id = Supabase.Scalars.UUID.fromString "123"
    , name = "Ryan Haskell-Glatz"
    , email = "ryan@jangle.io"
    , image = Nothing
    , supabaseToken = "supabase_123"
    , github =
        Just
            { token = "github_123"
            , username = "ryannhg"
            }
    }


toAuthenticatedProgramTest :
    { page :
        Auth.User
        -> Shared.Model
        -> Route params
        -> Page model msg
    , url : String
    , params : params
    , flags : Json.Encode.Value
    }
    -> ProgramTest model msg (Effect msg)
toAuthenticatedProgramTest props =
    let
        toUrl : String -> Url
        toUrl url =
            Url.fromString url
                |> Maybe.withDefault fallbackUrl

        fallbackUrl : Url
        fallbackUrl =
            { protocol = Url.Https
            , host = "app.jangle.io"
            , port_ = Nothing
            , path = "/"
            , query = Nothing
            , fragment = Nothing
            }

        shared : Shared.Model
        shared =
            Shared.init
                (Json.Decode.decodeValue Shared.decoder props.flags)
                (Route.fromUrl () (toUrl props.url))
                |> Tuple.first

        route : Route params
        route =
            Route.fromUrl
                props.params
                (toUrl props.url)

        page : Page model msg
        page =
            props.page user shared route
    in
    ProgramTest.createDocument
        { init = Page.init page
        , update = Page.update page
        , view = Page.view page
        }
        |> ProgramTest.start ()


toProgramTest :
    { page :
        Shared.Model
        -> Route params
        -> Page model msg
    , url : String
    , params : params
    , flags : Json.Encode.Value
    }
    -> ProgramTest model msg (Effect msg)
toProgramTest props =
    toAuthenticatedProgramTest
        { page = \_ -> props.page
        , url = props.url
        , params = props.params
        , flags = props.flags
        }


{-| Send a message
-}
sendMsg :
    msg
    -> ProgramTest model msg (Effect msg)
    -> ProgramTest model msg (Effect msg)
sendMsg msg =
    ProgramTest.simulateLastEffect
        (\_ -> Ok [ msg ])
