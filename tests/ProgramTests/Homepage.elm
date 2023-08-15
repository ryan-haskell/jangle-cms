module ProgramTests.Homepage exposing (..)

import Effect exposing (Effect)
import Json.Encode
import Pages.Home_ exposing (Model, Msg)
import ProgramTest exposing (ProgramTest)
import Supabase.Queries.MyProjects
import Supabase.Scalars.UUID
import Test exposing (Test)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Selector
import Tests.Page



-- PROGRAM TESTS


start : ProgramTest Model Msg (Effect Msg)
start =
    Tests.Page.toAuthenticatedProgramTest
        { page = Pages.Home_.page
        , url = "https://app.jangle.io"
        , params = ()
        , flags = Json.Encode.null
        }


startWithNoExistingProjects : ProgramTest Model Msg (Effect Msg)
startWithNoExistingProjects =
    start
        |> Tests.Page.sendMsg (fetchedExistingProjects [])


startWithExistingProjects : ProgramTest Model Msg (Effect Msg)
startWithExistingProjects =
    start
        |> Tests.Page.sendMsg
            (fetchedExistingProjects
                [ "@jangle-cms/app"
                , "@ryannhg/rhg_dev"
                ]
            )



-- TEST SUITE


suite : Test
suite =
    Test.describe "Homepage"
        [ Test.test "Page shows loading message while fetching existing projects" <|
            \() ->
                start
                    |> ProgramTest.expectViewHas
                        [ Selector.text "Loading..."
                        ]
        , Test.describe "When there are no existing projects"
            [ Test.test "Show 'Create new project'" <|
                \() ->
                    startWithNoExistingProjects
                        |> ProgramTest.expectViewHas
                            [ Selector.text "Create new project"
                            ]
            ]
        , Test.describe "When there are existing projects"
            [ Test.test "Show existing projects as links" <|
                \() ->
                    startWithExistingProjects
                        |> ProgramTest.expectViewHas
                            [ Selector.text "@jangle-cms/app"
                            ]
            , Test.test "Show 'Create another project' button" <|
                \() ->
                    startWithExistingProjects
                        |> ProgramTest.expectViewHas
                            [ Selector.text "Create another project"
                            ]
            ]
        ]



-- MSGS


fetchedExistingProjects : List String -> Pages.Home_.Msg
fetchedExistingProjects projectNames =
    let
        toProject : String -> Supabase.Queries.MyProjects.Project
        toProject name =
            { id = Supabase.Scalars.UUID.fromString "123"
            , title = name
            , github_repo_id = "123"
            }
    in
    Pages.Home_.FetchedExistingProjects
        (Ok
            { projects =
                Just
                    { edges = List.map (\p -> { node = toProject p }) projectNames
                    }
            }
        )
