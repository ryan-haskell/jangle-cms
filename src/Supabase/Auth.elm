module Supabase.Auth exposing
    ( User, getUserData
    , GitHubUserMetadata
    , toGitHubOAuthUrl
    )

{-|


## Fetch user data

@docs User, getUserData
@docs GitHubUserMetadata

-}

import Dict exposing (Dict)
import Http
import Json.Decode
import Json.Encode
import Supabase.Context exposing (Context)
import Supabase.Request
import Url.Builder


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



-- GET USER DATA


type alias User =
    { id : String
    , email : String
    , github : Maybe GitHubUserMetadata
    }


userDecoder : Json.Decode.Decoder User
userDecoder =
    Json.Decode.map3 User
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "email" Json.Decode.string)
        (Json.Decode.maybe (Json.Decode.field "user_metadata" githubUserMetadataDecoder))


type alias GitHubUserMetadata =
    { id : String
    , username : String
    , name : Maybe String
    , avatar_url : Maybe String
    }


githubUserMetadataDecoder : Json.Decode.Decoder GitHubUserMetadata
githubUserMetadataDecoder =
    Json.Decode.map4 GitHubUserMetadata
        (Json.Decode.field "provider_id" Json.Decode.string)
        (Json.Decode.field "user_name" Json.Decode.string)
        (Json.Decode.maybe (Json.Decode.field "name" Json.Decode.string))
        (Json.Decode.maybe (Json.Decode.field "avatar_url" Json.Decode.string))


getUserData :
    { onResponse : Result Http.Error User -> msg
    }
    -> Context
    -> Supabase.Request.Request User msg
getUserData props context =
    Supabase.Context.toHttpRequest
        { method = "GET"
        , endpoint = "/auth/v1/user"
        , body = Http.emptyBody
        , decoder = userDecoder
        , onResponse = props.onResponse
        }
        context



-- INTERNALS


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


{-| More on scopes here:
<https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/scopes-for-oauth-apps>
-}
toGitHubOAuthUrl :
    { redirectTo : String
    , supabaseUrl : String
    , scopes : List String
    }
    -> String
toGitHubOAuthUrl { redirectTo, supabaseUrl, scopes } =
    let
        queryParams : String
        queryParams =
            [ Url.Builder.string "provider" "github"
                |> Just
            , Url.Builder.string "redirect_to" redirectTo
                |> Just
            , if List.isEmpty scopes then
                Nothing

              else
                Url.Builder.string "scopes" (String.join " " scopes)
                    |> Just
            ]
                |> List.filterMap identity
                |> Url.Builder.toQuery
    in
    supabaseUrl ++ "/auth/v1/authorize" ++ queryParams
