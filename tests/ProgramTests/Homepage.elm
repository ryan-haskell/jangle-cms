module ProgramTests.Homepage exposing (..)

import Effect exposing (Effect)
import Pages.Home_ exposing (Model, Msg)
import ProgramTest exposing (..)
import Route.Path
import Test exposing (..)
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
    describe "Homepage"
        [ describe "Increment button"
            [ test "Page starts with counter value of 0" <|
                \() ->
                    start
                        |> expectViewHas [ text "Counter: 0" ]
            , test "Clicking increment button updates counter to 1" <|
                \() ->
                    start
                        |> clickButton "Increment"
                        |> expectViewHas [ text "Counter: 1" ]
            , test "Clicking increment button twice updates the counter to 2" <|
                \() ->
                    start
                        |> clickButton "Increment"
                        |> clickButton "Increment"
                        |> expectViewHas [ text "Counter: 2" ]
            ]
        ]
