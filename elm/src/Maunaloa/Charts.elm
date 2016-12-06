module Maunaloa.Charts exposing (..)

import Http
import Task
import Html.App as App
import Html as H
import Html.Attributes as A
-- import Common.ModalDialog exposing (ModalDialog, dlgOpen, dlgClose, makeOpenDlgButton, modalDialog)
import Common.ComboBox
    exposing
        ( SelectItems
        , comboBoxItemListDecoder
        , makeSelect
        , onChange
        )


mainUrl = "/maunaloa"

main : Program Never
main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-----------------------------------------------
-------------------- IMIT ---------------------
-----------------------------------------------


init : ( Model, Cmd Msg )
init =
    ( initModel, fetchTickers )



-----------------------------------------------
------------------- MODEL ---------------------
-----------------------------------------------


type alias Model =
    { tickers : Maybe SelectItems
    , selectedTicker : String
    }


initModel : Model
initModel =
    { tickers = Nothing
    , selectedTicker = "-1"
    }



-----------------------------------------------
-------------------- MSG ----------------------
-----------------------------------------------


type Msg
    = FetchFail String
    | TickersFetched SelectItems
    | FetchCharts String



-----------------------------------------------
-------------------- VIEW ---------------------
-----------------------------------------------


view : Model -> H.Html Msg
view model =
    H.div [ A.class "container" ]
        [ H.div [ A.class "row" ]
            [ makeSelect "Tickers: " FetchCharts model.tickers model.selectedTicker
            ]
        , H.div [ A.id "chart1", A.style [("position", "absolute"), ("top","200px"), ("left","200px")] ]
            [ 
            ]
        ]



-----------------------------------------------
------------------- UPDATE --------------------
-----------------------------------------------


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchFail s ->
            Debug.log ("FetchFail: " ++ s) ( model, Cmd.none )

        TickersFetched s ->
            Debug.log "TickersFetched" 
            ( { model
                | tickers = Just s
              }
            , Cmd.none
            )

        FetchCharts s ->
            Debug.log "FetchCharts" 
            ( { model | selectedTicker = s }, Cmd.none )



-----------------------------------------------
------------------ COMMANDS -------------------
-----------------------------------------------


fetchTickers : Cmd Msg
fetchTickers =
    let
        url =
            mainUrl ++ "/tickers"
    in
        Http.get comboBoxItemListDecoder url
            |> Task.mapError toString
            |> Task.perform FetchFail TickersFetched



-----------------------------------------------
---------------- SUBSCRIPTIONS ----------------
-----------------------------------------------


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
