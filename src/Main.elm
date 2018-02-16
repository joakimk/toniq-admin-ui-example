port module Main exposing (..)

import Color
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (onClick)
import Html
import Style exposing (..)
import Style.Border exposing (rounded)
import Style.Color as Color
import Style.Font as Font


---- PORTS ----


port serverStateUpdate : (ServerState -> msg) -> Sub msg


port outgoingCommand : String -> Cmd msg



---- MODEL ----


type alias Job =
    { id : String
    , worker : String
    }


type alias ServerState =
    { failedJobs : List Job
    }


type alias Model =
    { serverState : Maybe ServerState
    , someLocalState : String
    }


initialModel : Model
initialModel =
    { serverState = Nothing, someLocalState = "Check your browser console when pressing \"Retry\"..." }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp
    | UpdateServerState ServerState
    | RetryJob Job


subscriptions model =
    [ serverStateUpdate UpdateServerState
    ]
        |> Sub.batch


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UpdateServerState serverState ->
            ( { model | serverState = Just serverState }, Cmd.none )

        RetryJob job ->
            ( { model | someLocalState = "Sent retry request" }
            , outgoingCommand ("retryJob:" ++ job.id)
            )



---- VIEW ----


view model =
    Element.viewport stylesheet <|
        row None
            [ padding 30, spacing 20 ]
            [ column Box
                [ spacing 20, padding 20, width (px 300) ]
                [ header Header [] (text "Failed jobs")
                , viewFailedJobs model
                ]

            -- This could be anything that we don't get from the server and only change locally like what view you are currently looking at.
            , paragraph Box
                [ padding 20, width (px 300) ]
                [ text model.someLocalState
                ]
            ]


viewFailedJobs model =
    case model.serverState of
        Just serverState ->
            -- Possibly use a table here
            column None
                [ spacing 20 ]
                (serverState.failedJobs |> List.map viewFailedJob)

        Nothing ->
            text "Loading..."


viewFailedJob job =
    column None
        []
        [ text ("ID: " ++ job.id)
        , text ("Worker: " ++ job.worker)
        , button Button
            [ width (px 75)
            , padding 5
            , onClick (RetryJob job)
            ]
            (text "Retry")
        ]


type Styles
    = None
    | Header
    | Button
    | Box


type StyleVariations
    = NoVariation


stylesheet : StyleSheet Styles StyleVariations
stylesheet =
    Style.styleSheet
        [ style None []
        , style Header
            [ Font.size 24
            ]
        , style Button
            [ Color.background Color.gray
            ]
        , style Box
            [ Color.background Color.darkCharcoal
            , Color.text Color.white
            , rounded 5
            ]
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
