module ProgramTests.Homepage exposing (..)

import Effect exposing (Effect)
import Pages.Home_ exposing (Model, Msg)
import ProgramTest exposing (ProgramTest)
import Route.Path
import Test exposing (Test)
import Test.Html.Selector exposing (text)



-- DESCRIBE HOMEPAGE


start : ProgramTest Model Msg (Effect Msg)
start =
    ProgramTest.createDocument
        { init = Pages.Home_.init
        , update = Pages.Home_.update
        , view = Pages.Home_.view Route.Path.Home_
        }
        |> ProgramTest.start ()



-- TEST SUITE


suite : Test
suite =
    Test.describe "Homepage"
        [ Test.describe "Create your first project"
            [ Test.test "Page has button with label 'Create new project'" <|
                \() ->
                    start
                        |> ProgramTest.expectViewHas [ text "Create new project" ]

            -- , Test.skip <|
            --     Test.test "Clicking 'Create new project' button shows a dialog" <|
            --         \() ->
            --             start
            --                 |> ProgramTest.clickButton "Create new project"
            --                 |> ProgramTest.expectViewHas [ text "Create a project" ]
            ]
        ]
