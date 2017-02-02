port module Maunaloa.Charts exposing (..)

import Http
import Task
import Html as H
import Html.Attributes as A
import Svg as S
import Svg.Attributes as SA
import Json.Decode as Json
import Json.Decode.Pipeline as JP

import Common.Miscellaneous as M
import Common.DateUtil as DU
import ChartRuler.HRuler as HR


-- import Common.ModalDialog exposing (ModalDialog, dlgOpen, dlgClose, makeOpenDlgButton, modalDialog)

import Common.Miscellaneous exposing (makeLabel, onChange, stringToDateDecoder)
import Common.ComboBox
    exposing
        ( ComboBoxItem
        , SelectItems
        , comboBoxItemListDecoder
        , makeSelect
        )
import ChartRuler.VRuler as VR
import ChartCommon exposing (Candlestick, ChartInfo)


mainUrl =
    "/maunaloa"


main : Program Never Model Msg
main =
    H.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-------------------- PORTS ---------------------


port drawCanvas : ( List (List Float), List Float, List String ) -> Cmd msg



-------------------- INIT ---------------------


init : ( Model, Cmd Msg )
init =
    ( initModel, fetchTickers )



------------------- MODEL ---------------------
{-
   , spots : Maybe (List Float)
   , candlesticks : Maybe (List Candlestick)
-}


type alias Model =
    { tickers : Maybe SelectItems
    , selectedTicker : String
    , chartInfo : Maybe ChartInfo
    , chartInfoWin : Maybe ChartInfo
    , dropItems : Int
    , takeItems : Int
    }


initModel : Model
initModel =
    { tickers = Nothing
    , selectedTicker = "-1"
    , chartInfo = Nothing
    , chartInfoWin = Nothing
    , dropItems = 0 
    , takeItems = 90 
    }



------------------- TYPES ---------------------
--


type Msg
    = TickersFetched (Result Http.Error SelectItems)
    | FetchCharts String
    | ChartsFetched (Result Http.Error ChartInfo)



-------------------- VIEW ---------------------


view : Model -> H.Html Msg
view model =
    let
        w =
            1300

        h =
            600

        ws =
            toString w

        hs =
            toString h

        stroke =
            "#023963"

        svgBaseLines =
            [ S.line [ SA.x1 "0", SA.y1 "0", SA.x2 "0", SA.y2 hs, SA.stroke stroke ] []
              --, S.line [ SA.x1 "0", SA.y1 hs, SA.x2 ws, SA.y2 hs, SA.stroke stroke ] []
              -- , S.line [ SA.x2 "0", SA.y1 "0", SA.x2 ws, SA.y2 "0", SA.stroke stroke ] []
            ]

        hruler =
            case model.chartInfoWin of
                Nothing ->
                    []

                Just ci ->
                    []

        vruler =
            case model.chartInfoWin of
                Nothing ->
                    []

                Just ci ->
                    VR.lines w h ci
    in
        H.div [ A.class "container" ]
            [ H.div [ A.class "row" ]
                [ makeSelect "Tickers: " FetchCharts model.tickers model.selectedTicker
                ]
            , H.div [ A.style [ ( "position", "absolute" ), ( "top", "200px" ), ( "left", "200px" ) ] ]
                [ S.svg [ SA.width (ws ++ "px"), SA.height (hs ++ "px") ]
                    (List.append
                        svgBaseLines
                        (List.append hruler vruler)
                    )
                ]
            ]



------------------- UPDATE --------------------

chartWindow : ChartInfo -> Int -> Int -> ChartInfo 
chartWindow ci offset numItems = 
    let 
        xAxis_ = List.take numItems <| List.drop offset ci.xAxis         
        (minDx_,maxDx_) = HR.dateRangeOf ci xAxis_
        spots_ = case ci.spots of 
                    Nothing -> Nothing
                    Just s -> Just <| List.take numItems <| List.drop offset s
    in 
        { minDx = minDx_
        , maxDx = maxDx_ 
        , xAxis = xAxis_ 
        , spots = spots_ 
        , itrend20 = Nothing 
        }

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TickersFetched (Ok s) ->
            Debug.log "TickersFetched"
                ( { model
                    | tickers = Just s
                  }
                , Cmd.none
                )

        TickersFetched (Err s) ->
            Debug.log "TickersFetched Error" ( model, Cmd.none )

        FetchCharts s ->
            Debug.log "FetchCharts"
                ( { model | selectedTicker = s }, fetchCharts s )

        ChartsFetched (Ok s) ->
            let 
                ciWin = chartWindow s model.dropItems model.takeItems 
            in
                ( { model | chartInfo = Just s, chartInfoWin = Just ciWin }, drawChartInfo ciWin )

        ChartsFetched (Err _) ->
            Debug.log "ChartsFetched err"
                ( model, Cmd.none )


drawChartInfo : ChartInfo -> Cmd Msg
drawChartInfo ci =
    let
        spots =
            Maybe.withDefault [] ci.spots

        itrend20 =
            Maybe.withDefault [] ci.itrend20
    in
        Debug.log (toString ci)
            drawCanvas
            ( [ spots, itrend20 ], ci.xAxis, [ "#000000", "#ff0000" ] )



------------------ COMMANDS -------------------


fetchTickers : Cmd Msg
fetchTickers =
    let
        url =
            mainUrl ++ "/tickers"
    in
        Http.send TickersFetched <|
            Http.get url comboBoxItemListDecoder


fetchCharts : String -> Cmd Msg
fetchCharts ticker =
    let
        myDecoder =
            JP.decode ChartInfo
                |> JP.required "min-dx" stringToDateDecoder
                |> JP.required "max-dx" stringToDateDecoder
                |> JP.required "x-axis" (Json.list Json.float)
                |> JP.required "spots" (Json.nullable (Json.list Json.float))
                |> JP.required "itrend-20" (Json.nullable (Json.list Json.float))

        url =
            mainUrl ++ "/ticker?oid=" ++ ticker
    in
        Http.send ChartsFetched <| Http.get url myDecoder



---------------- SUBSCRIPTIONS ----------------


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
