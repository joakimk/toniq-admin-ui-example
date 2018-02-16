port module Main exposing (..)

import Html exposing (Html, text, div, h1, img, button)
import Html.Attributes exposing (src, class)
import Html.Events exposing (onClick)


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


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Example" ]

        -- This could be anything that we don't get from the server and only change locally like what view you are currently looking at.
        , text model.someLocalState
        , viewFailedJobs model
        ]


viewFailedJobs : Model -> Html Msg
viewFailedJobs model =
    case model.serverState of
        Just serverState ->
            div [] (serverState.failedJobs |> List.map viewFailedJob)

        Nothing ->
            text "Loading..."


viewFailedJob job =
    div [ class "job" ]
        [ div [] [ text ("ID: " ++ job.id) ]
        , div [] [ text ("Worker: " ++ job.worker) ]
        , button [ onClick (RetryJob job) ] [ text "Retry" ]
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
