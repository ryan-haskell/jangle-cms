module Auth exposing (User, onPageLoad, viewLoadingPage)

import Auth.Action
import Auth.User
import Dict
import Route exposing (Route)
import Route.Path
import Shared
import Shared.Model
import View exposing (View)


type alias User =
    Auth.User.User


{-| Called before an auth-only page is loaded.
-}
onPageLoad : Shared.Model -> Route () -> Auth.Action.Action User
onPageLoad shared route =
    case shared.user of
        Auth.User.SignedIn user ->
            Auth.Action.loadPageWithUser user

        Auth.User.FetchingUserDetails response ->
            Auth.Action.showLoadingPage
                { title = "Signing in..."
                , body = []
                }

        Auth.User.NotSignedIn ->
            Auth.Action.pushRoute
                { path = Route.Path.SignIn
                , query = Dict.empty
                , hash = Nothing
                }


{-| Renders whenever `Auth.Action.showLoadingPage` is returned from `onPageLoad`.
-}
viewLoadingPage : Shared.Model -> Route () -> View Never
viewLoadingPage shared route =
    { title = "Signing in..."
    , body = []
    }
