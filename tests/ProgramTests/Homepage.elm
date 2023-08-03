module ProgramTests.Homepage exposing (..)

import Effect exposing (Effect)
import Json.Encode
import Pages.Home_ exposing (Model, Msg)
import ProgramTest exposing (ProgramTest)
import Route.Path
import Test exposing (Test)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector as Selector
import Tests.Mock



-- DESCRIBE HOMEPAGE


start : ProgramTest Model Msg (Effect Msg)
start =
    ProgramTest.createDocument
        { init = Pages.Home_.init Tests.Mock.user
        , update = Pages.Home_.update Tests.Mock.user
        , view = Pages.Home_.view Tests.Mock.user
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
                        |> ProgramTest.expectViewHas
                            [ Selector.text "Create new project"
                            ]
            ]
        ]
