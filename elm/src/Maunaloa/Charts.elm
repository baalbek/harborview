module Maunaloa.Charts exposing (..)

import Http
import Task
import Html.App as App
import Html as H
import Html.Attributes as A
import Svg as S
import Svg.Attributes as SA
import Json.Decode as Json exposing ((:=))
import Json.Decode.Pipeline as JP 
import Date exposing (Date)


-- import Common.ModalDialog exposing (ModalDialog, dlgOpen, dlgClose, makeOpenDlgButton, modalDialog)


import Common.Miscellaneous exposing (makeLabel,onChange,stringToDateDecoder)
import Common.ComboBox
    exposing
        ( ComboBoxItem
        , SelectItems
        , comboBoxItemListDecoder
        , makeSelect
        )
import ChartRuler.VRuler as VR
import ChartCommon exposing (Candlestick)

mainUrl =
    "/maunaloa"


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

type alias ChartInfo =
    { minDx : Date  
    , maxDx : Date  
    , spots : Maybe (List Float)
    }

    {-
    , spots : Maybe (List Float)
    , candlesticks : Maybe (List Candlestick)
    -}

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
------------------- TYPES ---------------------
-----------------------------------------------
--


type Msg
    = FetchFail String
    | TickersFetched SelectItems
    | FetchCharts String
    | ChartsFetched ChartInfo 


-----------------------------------------------
-------------------- VIEW ---------------------
-----------------------------------------------


view : Model -> H.Html Msg
view model =
    let 
        w = "1200"
        h = "300"
    in 
    H.div [ A.class "container" ]
        [ H.div [ A.class "row" ]
            [ makeSelect "Tickers: " FetchCharts model.tickers model.selectedTicker
            ]
        , H.div [ A.style [ ( "position", "absolute" ), ( "top", "200px" ), ( "left", "200px" ) ] ]
            [ S.svg [ SA.width (w ++ "px"), SA.height (h ++ "px") ]
                [ S.line [ SA.x1 "0", SA.y1 "0", SA.x2 "0", SA.y2 h, SA.stroke "#023963" ] []
                , S.line [ SA.x1 "0", SA.y1 h, SA.x2 w, SA.y2 h, SA.stroke "#023963" ] []
                ]
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
                ( { model | selectedTicker = s }, fetchCharts s )

        ChartsFetched s ->
            Debug.log (toString s) 
                ( model, Cmd.none )



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



fetchCharts : String -> Cmd Msg
fetchCharts ticker = 
    let
        myDecoder =
            JP.decode ChartInfo
                |> JP.required "min-dx" stringToDateDecoder 
                |> JP.required "max-dx" stringToDateDecoder 
                |> JP.required "spots" (Json.nullable (Json.list Json.float))

        url =
            mainUrl ++ "/ticker?oid=" ++ ticker
    in
        Http.get myDecoder url
            |> Task.mapError toString
            |> Task.perform FetchFail ChartsFetched 
{-
    let
        myDecoder =
            Json.object3
                TripleComboBoxList
                ("daily" := Json.list Json.float)
                ("itrend" := Json.list Json.float)
                ("dx" := Json.list stringToDateDecoder)

        url =
            mainUrl ++ "/ticker?oid=" ++ ticker
    in
        Http.get myDecoder url
            |> Task.mapError toString
            |> Task.perform FetchFail ChartsFetched 

-}

-----------------------------------------------
---------------- SUBSCRIPTIONS ----------------
-----------------------------------------------


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
