module Supabase.Auth exposing (signInWithOAuth)

import Http
import Json.Decode
import Json.Encode


type Context
    = Context
        { url : String
        , apiKey : String
        , timeout : Maybe Float
        , tracker : Maybe String
        }


{-| Options when signing in via OAuth:

  - `queryParams` - An object of query params
  - `redirectTo` - A URL to send the user to after they are confirmed.
  - `scopes` - A list of scopes granted to the OAuth application.
  - `skipBrowserRedirect`- If set to true does not immediately redirect the current browser context to visit the OAuth authorization page for the provider.

-}
type alias SignInWithOAuthOptions =
    { queryParams : List ( String, Json.Encode.Value )
    , redirectTo : Maybe String
    , scopes : List String
    , skipBrowserRedirect : Maybe Bool
    }


{-| Source: <https://github.com/supabase/gotrue-js/blob/67eb6169aeb1b1a42d7c7e7cbf6336aef79e55de/src/lib/types.ts#L5>
-}
type OAuthProvider
    = Apple
    | Azure
    | Bitbucket
    | Discord
    | Facebook
    | Figma
    | Github
    | Gitlab
    | Google
    | Kakao
    | Keycloak
    | Linkedin
    | Notion
    | Slack
    | Spotify
    | Twitch
    | Twitter
    | Workos
    | Zoom


fromProviderToString : OAuthProvider -> String
fromProviderToString provider =
    case provider of
        Apple ->
            "apple"

        Azure ->
            "azure"

        Bitbucket ->
            "bitbucket"

        Discord ->
            "discord"

        Facebook ->
            "facebook"

        Figma ->
            "figma"

        Github ->
            "github"

        Gitlab ->
            "gitlab"

        Google ->
            "google"

        Kakao ->
            "kakao"

        Keycloak ->
            "keycloak"

        Linkedin ->
            "linkedin"

        Notion ->
            "notion"

        Slack ->
            "slack"

        Spotify ->
            "spotify"

        Twitch ->
            "twitch"

        Twitter ->
            "twitter"

        Workos ->
            "workos"

        Zoom ->
            "zoom"


signInWithOAuth :
    Context
    ->
        { provider : OAuthProvider
        , options : Maybe SignInWithOAuthOptions
        , onResponse : Result Http.Error OAuthResponse -> msg
        }
    -> Cmd msg
signInWithOAuth (Context context) props =
    Http.request
        { method = "POST"
        , url = context.url ++ "/auth/v1/authorize"
        , headers =
            [ Http.header "apikey" context.apiKey
            , Http.header "Content-Type" "application/json"
            ]
        , body =
            Http.jsonBody
                (Json.Encode.object
                    [ ( "provider"
                      , Json.Encode.string (fromProviderToString props.provider)
                      )
                    ]
                )
        , expect =
            Http.expectJson
                props.onResponse
                (Json.Decode.succeed {})
        , timeout = context.timeout
        , tracker = context.tracker
        }


type alias OAuthResponse =
    {}
