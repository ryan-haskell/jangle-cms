module Components.EmptyState exposing
    ( viewCreateYourFirstContentType
    , viewCreateYourFirstProject
    , viewHttpError
    , viewLoading
    , viewNoResultsFound
    )

import Components.Button
import Css
import Html exposing (..)
import Http
import Svg
import Svg.Attributes


viewCreateYourFirstProject :
    { id : String
    , onClick : msg
    }
    -> Html msg
viewCreateYourFirstProject props =
    viewEmptyStateWithOptions
        { image = viewWindAndLeavesSvg
        , title = "Create your first project"
        , subtitle = "Welcome to Jangle! Let's get started by connecting to any existing GitHub repository."
        , button =
            { label = "Create new project"
            , id = props.id
            , onClick = props.onClick
            }
        }


viewCreateYourFirstContentType :
    { id : String
    , onClick : msg
    }
    -> Html msg
viewCreateYourFirstContentType props =
    viewEmptyStateWithOptions
        { image = viewWindAndLeavesSvg
        , title = "Let's get started"
        , subtitle = "Next, let's define our first \"content type\" to define what kind of content we want to manage."
        , button =
            { label = "Create a content type"
            , id = props.id
            , onClick = props.onClick
            }
        }



-- INTERNALS


viewEmptyStateWithOptions :
    { image : Html msg
    , title : String
    , subtitle : String
    , button :
        { id : String
        , label : String
        , onClick : msg
        }
    }
    -> Html msg
viewEmptyStateWithOptions props =
    section
        [ Css.col
        , Css.gap_24
        , Css.text_center
        , Css.align_cx
        ]
        [ div
            [ Css.col
            , Css.gap_8
            , Css.align_cx
            ]
            [ props.image
            , h3 [ Css.font_h1 ] [ text props.title ]
            , p
                [ Css.mw_320
                , Css.font_sublabel
                , Css.color_textSecondary
                , Css.line_140
                ]
                [ text props.subtitle ]
            ]
        , Components.Button.new { label = props.button.label }
            |> Components.Button.withOnClick props.button.onClick
            |> Components.Button.withId props.button.id
            |> Components.Button.view
        ]


viewLoading : Html msg
viewLoading =
    viewPlaceholderMessage
        { viewIcon =
            div [ Css.spinner ]
                [ div [] []
                , div [] []
                , div [] []
                , div [] []
                ]
        , message = "Loading..."
        }


viewPlaceholderMessage :
    { viewIcon : Html msg
    , message : String
    }
    -> Html msg
viewPlaceholderMessage props =
    div
        [ Css.row
        , Css.gap_8
        , Css.h_180
        , Css.align_center
        ]
        [ props.viewIcon
        , span
            [ Css.font_sublabel
            , Css.color_textSecondary
            ]
            [ text props.message ]
        ]


viewNoResultsFound : String -> Html msg
viewNoResultsFound message =
    viewPlaceholderMessage
        { viewIcon = viewErrorTriangle12px
        , message = message
        }


viewHttpError : Http.Error -> Html msg
viewHttpError httpError =
    let
        message : String
        message =
            case httpError of
                Http.BadBody _ ->
                    "Got an unexpected API response"

                Http.Timeout ->
                    "Request timed out"

                Http.NetworkError ->
                    "Could not connect to the API"

                Http.BadStatus code ->
                    "Got status code " ++ String.fromInt code

                Http.BadUrl _ ->
                    "This request had an invalid URL"
    in
    viewPlaceholderMessage
        { viewIcon = viewErrorTriangle12px
        , message = message
        }


viewWindAndLeavesSvg : Svg.Svg msg
viewWindAndLeavesSvg =
    Svg.svg
        [ Svg.Attributes.width "240"
        , Svg.Attributes.height "240"
        , Svg.Attributes.viewBox "0 0 240 240"
        , Svg.Attributes.fill "none"
        ]
        [ Svg.path
            [ Svg.Attributes.fillRule "evenodd"
            , Svg.Attributes.clipRule "evenodd"
            , Svg.Attributes.d "M18.9787 128.959C38.1374 120.627 41.0174 109.977 40.6049 102.998C40.5487 94.8415 33.8474 88.1815 25.6087 88.1815C18.1424 88.1815 11.9437 93.6487 10.7962 100.793C10.4699 102.837 11.8612 104.764 13.9049 105.09C15.9487 105.42 17.8762 104.025 18.2024 101.982C18.7762 98.4115 21.8774 95.6815 25.6087 95.6815C29.7487 95.6815 33.1087 99.0415 33.1087 103.182C33.1087 103.257 33.1124 103.335 33.1162 103.41C33.4349 108.637 30.3749 115.823 15.9899 122.082C14.0887 122.907 13.2187 125.119 14.0437 127.017C14.8724 128.914 17.0812 129.784 18.9787 128.959Z"
            , Svg.Attributes.fill "var(--color_primary)"
            ]
            []
        , Svg.path
            [ Svg.Attributes.fillRule "evenodd"
            , Svg.Attributes.clipRule "evenodd"
            , Svg.Attributes.d "M18.8362 129.015C47.3249 117.994 64.3013 107.202 96.2849 106.77C98.3549 106.74 100.013 105.038 99.9827 102.968C99.9563 100.902 98.2535 99.2437 96.1835 99.2701C63.1499 99.7165 45.5512 110.637 16.1324 122.022C14.2012 122.767 13.2412 124.943 13.9874 126.874C14.7337 128.802 16.9087 129.765 18.8362 129.015Z"
            , Svg.Attributes.fill "var(--color_primary)"
            ]
            []
        , Svg.path
            [ Svg.Attributes.fillRule "evenodd"
            , Svg.Attributes.clipRule "evenodd"
            , Svg.Attributes.d "M19.6087 151.11C50.3962 129.968 67.8113 122.49 130.028 121.77C197.193 120.99 207.296 87.0528 206.726 73.095C206.685 59.6964 195.78 48.8172 182.355 48.8172C168.9 48.8172 157.98 59.7414 157.98 73.1928C157.98 82.425 163.121 90.4686 170.7 94.6014C172.515 95.595 174.795 94.9236 175.788 93.105C176.778 91.29 176.108 89.01 174.293 88.02C169.046 85.155 165.48 79.5864 165.48 73.1928C165.48 63.8778 173.04 56.3172 182.355 56.3172C191.666 56.3172 199.23 63.8778 199.23 73.1928C199.23 73.245 199.23 73.3014 199.233 73.3536C199.766 85.68 189.51 113.58 129.941 114.27C65.3513 115.02 47.3249 122.978 15.3599 144.93C13.6537 146.1 13.2224 148.436 14.3924 150.142C15.5662 151.849 17.9024 152.284 19.6087 151.11Z"
            , Svg.Attributes.fill "var(--color_primary)"
            ]
            []
        , Svg.path
            [ Svg.Attributes.fillRule "evenodd"
            , Svg.Attributes.clipRule "evenodd"
            , Svg.Attributes.d "M87.2437 151.013C97.5079 143.265 118.065 141.701 132.833 146.981C141.84 150.203 148.793 156.045 148.759 165.293C148.759 165.3 148.759 165.304 148.759 165.308C148.759 171.518 143.715 176.558 137.509 176.558C131.299 176.558 126.259 171.518 126.259 165.308C126.259 164.183 126.424 163.095 126.732 162.071C127.328 160.088 126.199 157.995 124.219 157.399C122.235 156.803 120.142 157.928 119.547 159.911C119.033 161.621 118.759 163.433 118.759 165.308C118.759 175.658 127.159 184.058 137.509 184.058C147.855 184.058 156.255 175.661 156.259 165.315C156.304 152.783 147.566 144.285 135.356 139.92C118.294 133.819 94.5829 136.073 82.7251 145.028C81.0715 146.273 80.7451 148.628 81.9901 150.278C83.2387 151.931 85.5937 152.258 87.2437 151.013Z"
            , Svg.Attributes.fill "var(--color_primary)"
            ]
            []
        , Svg.path
            [ Svg.Attributes.fillRule "evenodd"
            , Svg.Attributes.clipRule "evenodd"
            , Svg.Attributes.d "M163.928 133.016C180.319 132.161 198.679 138.33 205.504 149.921C206.554 151.706 208.853 152.303 210.637 151.253C212.419 150.203 213.015 147.9 211.965 146.119C203.967 132.525 182.757 124.523 163.538 125.524C161.472 125.633 159.882 127.399 159.99 129.465C160.099 131.531 161.862 133.121 163.928 133.016Z"
            , Svg.Attributes.fill "var(--color_primary)"
            ]
            []
        , Svg.path
            [ Svg.Attributes.fillRule "evenodd"
            , Svg.Attributes.clipRule "evenodd"
            , Svg.Attributes.d "M67.9465 74.7864C62.0929 76.635 55.7026 77.7978 50.5314 77.5236C49.4964 77.4678 48.7014 76.5864 48.7576 75.5514C48.8101 74.52 49.6951 73.725 50.7264 73.7778C57.3376 74.1264 66.1201 71.9886 72.7165 69.06C73.2379 68.8278 73.6279 68.3736 73.7701 67.8228C73.9165 67.2714 73.8037 66.6864 73.4629 66.2286C64.4365 54.0786 72.0079 34.6536 95.1451 26.145C109.927 20.7072 117.953 15.1914 122.01 10.6122C122.092 10.5222 122.164 10.425 122.224 10.3236C122.55 9.77225 123.154 9.44643 123.792 9.47643C124.41 9.50643 124.962 9.86643 125.243 10.4172C133.133 29.2014 124.433 54.675 110.239 67.6872C101.112 76.0578 89.6065 79.2036 78.8215 71.3514C77.9851 70.7436 76.8115 70.9278 76.2037 71.7636C75.5929 72.6 75.7765 73.7736 76.6165 74.385C89.0179 83.4114 102.278 80.0778 112.774 70.4514C128.01 56.4822 137.179 29.0772 128.697 8.95143C128.689 8.92863 128.678 8.91003 128.67 8.88724C127.812 7.04643 126.004 5.83144 123.975 5.73004C122.01 5.63644 120.15 6.60004 119.097 8.25004C115.245 12.525 107.637 17.5536 93.8515 22.6236C68.9401 31.7886 60.9937 52.6686 69.1429 66.4878C63.3715 68.745 56.3551 70.32 50.9251 70.035C47.8239 69.87 45.1764 72.255 45.0114 75.3564C44.8501 78.4578 47.2314 81.105 50.3326 81.27C55.8976 81.5628 62.7787 80.3514 69.0787 78.36C70.0651 78.0486 70.6129 76.995 70.3015 76.0086C69.9901 75.0228 68.9329 74.4714 67.9465 74.7864Z"
            , Svg.Attributes.fill "var(--color_textSecondary)"
            ]
            []
        , Svg.path
            [ Svg.Attributes.fillRule "evenodd"
            , Svg.Attributes.clipRule "evenodd"
            , Svg.Attributes.d "M30.5138 186.109C24.1463 189.233 17.7525 193.571 13.7063 198.064C11.6288 200.374 11.8163 203.933 14.1225 206.01C16.4325 208.088 19.9913 207.9 22.0688 205.59C25.7063 201.548 31.7813 197.7 37.455 195.218C41.4675 210.746 61.8528 219.896 85.9422 208.762C99.27 202.605 108.203 200.775 113.955 201.075C115.871 201.495 117.87 200.865 119.19 199.406C120.555 197.902 120.975 195.761 120.278 193.853C120.27 193.834 120.263 193.811 120.251 193.789C112.02 173.561 86.16 160.665 65.505 161.561C51.2775 162.176 39.5438 169.196 37.1588 184.35C36.9975 185.37 37.695 186.334 38.7188 186.491C39.7388 186.652 40.7025 185.955 40.8638 184.931C42.9375 171.754 53.295 165.844 65.67 165.308C84.9 164.471 109.054 176.325 116.756 195.142C116.97 195.758 116.835 196.418 116.411 196.886C115.984 197.359 115.328 197.558 114.705 197.396C114.589 197.366 114.472 197.348 114.353 197.34C108.244 196.976 98.67 198.75 84.3714 205.358C61.9914 215.7 42.9038 207.319 40.695 192.345C40.6125 191.782 40.2788 191.287 39.7875 190.999C39.2963 190.714 38.7 190.665 38.1675 190.871C31.4288 193.466 23.7075 198.165 19.2825 203.081C18.5888 203.85 17.4038 203.914 16.6313 203.22C15.8625 202.53 15.8025 201.341 16.4925 200.573C20.2613 196.388 26.2388 192.386 32.1675 189.476C33.0938 189.022 33.48 187.898 33.0225 186.968C32.5688 186.038 31.4438 185.655 30.5138 186.109Z"
            , Svg.Attributes.fill "var(--color_textSecondary)"
            ]
            []
        , Svg.path
            [ Svg.Attributes.fillRule "evenodd"
            , Svg.Attributes.clipRule "evenodd"
            , Svg.Attributes.d "M162.791 180.12C167.051 180.637 172.065 182.483 176.595 184.819C171.518 195.675 177.375 211.35 195.731 219.608C205.755 224.115 211.508 228.289 214.568 231.799C215.58 233.453 217.395 234.45 219.341 234.405C221.351 234.364 223.178 233.216 224.085 231.42C224.096 231.401 224.108 231.379 224.119 231.356C231.57 215.104 225.184 192.277 213.27 180.532C205.253 172.631 194.85 169.628 184.451 176.299C178.065 172.669 170.43 169.718 164.152 168.953C163.125 168.825 162.191 169.56 162.064 170.588C161.94 171.615 162.671 172.549 163.699 172.673C169.871 173.426 177.431 176.486 183.57 180.124C184.204 180.499 184.999 180.465 185.603 180.041C194.618 173.711 203.685 176.351 210.637 183.203C221.55 193.961 227.531 214.834 220.736 229.736C220.44 230.295 219.878 230.644 219.259 230.659C218.632 230.67 218.048 230.336 217.736 229.789C217.676 229.684 217.609 229.583 217.526 229.493C214.279 225.698 208.151 221.081 197.269 216.188C180.529 208.657 175.012 194.408 180.735 185.025C181.001 184.59 181.076 184.065 180.945 183.57C180.818 183.079 180.491 182.659 180.045 182.411C174.679 179.434 168.439 177.03 163.245 176.396C162.218 176.273 161.284 177.004 161.16 178.031C161.033 179.059 161.768 179.993 162.791 180.12Z"
            , Svg.Attributes.fill "var(--color_textSecondary)"
            ]
            []
        , Svg.path
            [ Svg.Attributes.fillRule "evenodd"
            , Svg.Attributes.clipRule "evenodd"
            , Svg.Attributes.d "M81.7086 66.6185C93.4236 62.2571 111.424 45.6563 117.69 32.0363C118.125 31.0949 117.712 29.9813 116.771 29.5463C115.83 29.1149 114.716 29.5272 114.285 30.4686C108.379 43.3086 91.4436 58.995 80.4 63.105C79.4322 63.465 78.9372 64.545 79.2978 65.5164C79.6578 66.4836 80.7378 66.9785 81.7086 66.6185Z"
            , Svg.Attributes.fill "var(--color_textSecondary)"
            ]
            []
        , Svg.path
            [ Svg.Attributes.fillRule "evenodd"
            , Svg.Attributes.clipRule "evenodd"
            , Svg.Attributes.d "M49.9125 189.278C54.15 187.159 60.7386 186.48 68.2086 186.652C79.8114 186.926 93.4836 189.349 104.141 192.33C105.139 192.608 106.174 192.023 106.455 191.029C106.733 190.031 106.148 188.996 105.154 188.719C94.2186 185.662 80.1978 183.184 68.2986 182.906C60.1014 182.711 52.8863 183.596 48.2325 185.921C47.31 186.386 46.9313 187.511 47.3963 188.438C47.8575 189.364 48.9863 189.739 49.9125 189.278Z"
            , Svg.Attributes.fill "var(--color_textSecondary)"
            ]
            []
        , Svg.path
            [ Svg.Attributes.fillRule "evenodd"
            , Svg.Attributes.clipRule "evenodd"
            , Svg.Attributes.d "M188.044 186.468C198.274 191.021 210.728 205.916 215.588 222.54C215.876 223.533 216.919 224.108 217.913 223.815C218.906 223.526 219.476 222.483 219.184 221.49C213.99 203.711 200.509 187.908 189.566 183.041C188.621 182.621 187.511 183.045 187.091 183.99C186.671 184.938 187.095 186.045 188.044 186.468Z"
            , Svg.Attributes.fill "var(--color_textSecondary)"
            ]
            []
        ]


viewErrorTriangle12px : Html msg
viewErrorTriangle12px =
    Svg.svg
        [ Svg.Attributes.viewBox "0 0 12 12"
        , Svg.Attributes.width "12"
        , Svg.Attributes.height "12"
        ]
        [ Svg.path
            [ Svg.Attributes.d "M4.855.708c.5-.896 1.79-.896 2.29 0l4.675 8.351a1.312 1.312 0 0 1-1.146 1.954H1.33A1.313 1.313 0 0 1 .183 9.058ZM7 7V3H5v4Zm-1 3a1 1 0 1 0 0-2 1 1 0 0 0 0 2Z"
            , Svg.Attributes.fill "currentColor"
            ]
            []
        ]
