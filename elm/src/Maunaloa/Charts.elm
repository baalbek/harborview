port module Maunaloa.Charts exposing (..)

import Date exposing (Date)
import Http
import Html as H
import Html.Attributes as A
import Svg as S
import Svg.Attributes as SA
import Json.Decode as Json
import Json.Decode.Pipeline as JP
import Common.Miscellaneous as M
import Common.DateUtil as DU
import ChartRuler.HRuler as HR
import ChartRuler.VRuler as VR
import Tuple as TUP


-- import Common.ModalDialog exposing (ModalDialog, dlgOpen, dlgClose, makeOpenDlgButton, modalDialog)

import Common.Miscellaneous exposing (checkbox, makeLabel, onChange, stringToDateDecoder)
import Common.ComboBox
    exposing
        ( ComboBoxItem
        , SelectItems
        , comboBoxItemListDecoder
        , makeSelect
        )
import ChartRuler.VRuler as VR
import ChartCommon as C exposing (Candlestick, ChartInfo, ChartInfoJs)


mainUrl =
    "/maunaloa"


type alias Flags =
    { isWeekly : Bool
    }



{-
   main : Program Never Model Msg
   main =
       H.program
           { init = init
           , view = view
           , update = update
           , subscriptions = subscriptions
           }

-}


main : Program Flags Model Msg
main =
    H.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-------------------- PORTS ---------------------


port drawCanvas : ChartInfoJs -> Cmd msg



-------------------- INIT ---------------------
{-
   init : ( Model, Cmd Msg )
   init =
       ( initModel, fetchTickers )
-}


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initModel flags, fetchTickers )



------------------- MODEL ---------------------


type alias Model =
    { tickers : Maybe SelectItems
    , selectedTicker : String
    , chartInfo : Maybe ChartInfo
    , chartInfoWin : Maybe ChartInfo
    , dropItems : Int
    , takeItems : Int
    , chartWidth : Float
    , chartHeight : Float
    , chartHeight2 : Float
    , flags : Flags
    }


initModel : Flags -> Model
initModel flags =
    { tickers = Nothing
    , selectedTicker = "-1"
    , chartInfo = Nothing
    , chartInfoWin = Nothing
    , dropItems = 0
    , takeItems = 90
    , chartWidth = 1300
    , chartHeight = 600
    , chartHeight2 = 300
    , flags = flags
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
            model.chartWidth + 100

        ws =
            toString w

        hs =
            toString model.chartHeight

        hs2 =
            toString model.chartHeight2

        stroke =
            "#023963"

        svgBaseLines =
            [ S.line [ SA.x1 "0", SA.y1 "0", SA.x2 "0", SA.y2 hs, SA.stroke stroke ] []
              --, S.line [ SA.x1 "0", SA.y1 hs, SA.x2 ws, SA.y2 hs, SA.stroke stroke ] []
              -- , S.line [ SA.x2 "0", SA.y1 "0", SA.x2 ws, SA.y2 "0", SA.stroke stroke ] []
            ]

        svgBaseLines2 =
            [ S.line [ SA.x1 "0", SA.y1 "0", SA.x2 "0", SA.y2 hs2, SA.stroke stroke ] []
              -- , S.line [ SA.x1 "0", SA.y1 hs2, SA.x2 ws, SA.y2 hs2, SA.stroke stroke ] []
            ]

        hruler =
            case model.chartInfoWin of
                Nothing ->
                    []

                Just ci ->
                    HR.lines w model.chartHeight ci

        vruler =
            case model.chartInfoWin of
                Nothing ->
                    []

                Just ci ->
                    VR.lines w model.chartHeight 10 ci

        hruler2 =
            case model.chartInfoWin of
                Nothing ->
                    []

                Just ci ->
                    HR.lines w model.chartHeight2 ci

        vruler2 =
            case model.chartInfoWin of
                Nothing ->
                    []

                Just ci ->
                    VR.lines w model.chartHeight2 5 ci
    in
        H.div [ A.class "container" ]
            [ H.div [ A.class "row" ]
                [ -- checkbox ToggleWeekly "Weekly"
                  makeSelect "Tickers: " FetchCharts model.tickers model.selectedTicker
                ]
            , H.div [ A.style [ ( "position", "absolute" ), ( "top", "300px" ), ( "left", "200px" ) ] ]
                [ S.svg [ SA.width (ws ++ "px"), SA.height (hs ++ "px") ]
                    (List.append
                        svgBaseLines
                        (List.append hruler vruler)
                    )
                ]
            , H.div [ A.style [ ( "position", "absolute" ), ( "top", "950px" ), ( "left", "200px" ) ] ]
                [ S.svg [ SA.width (ws ++ "px"), SA.height (hs2 ++ "px") ]
                    (List.append svgBaseLines2
                        (List.append hruler2 vruler2)
                    )
                ]
            ]



------------------- UPDATE --------------------


scaledCandlestick : (Float -> Float) -> Candlestick -> Candlestick
scaledCandlestick vruler cndl =
    let
        opn =
            vruler cndl.o

        hi =
            vruler cndl.h

        lo =
            vruler cndl.l

        cls =
            vruler cndl.c
    in
        Candlestick opn hi lo cls


chartWindow : ChartInfo -> Model -> ChartInfo
chartWindow ci model =
    let
        valueFn : List a -> List a
        valueFn vals =
            List.take model.takeItems <| List.drop model.dropItems vals

        xAxis_ =
            List.take model.takeItems <| List.drop model.dropItems ci.xAxis

        ( minDx_, maxDx_ ) =
            HR.dateRangeOf ci.minDx xAxis_

        hr =
            HR.hruler minDx_ maxDx_ xAxis_ model.chartWidth

        lines_ =
            List.map valueFn ci.lines

        valueRange =
            List.map VR.minMax lines_ |> M.minMaxTuples

        vr =
            VR.vruler valueRange model.chartHeight

        vrLines_ =
            List.map (List.map vr) lines_

        cndl_ =
            case ci.candlesticks of
                Nothing ->
                    Nothing

                Just cs ->
                    let
                        vr_cndl =
                            scaledCandlestick vr

                        my_cndls =
                            valueFn cs
                    in
                        Just (List.map vr_cndl my_cndls)
    in
        C.ChartInfo minDx_
            maxDx_
            (TUP.first valueRange)
            (TUP.second valueRange)
            (List.map hr xAxis_)
            vrLines_
            cndl_


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- ToggleWeekly ->
        -- ( { model | isWeekly = not model.isWeekly }, Cmd.none )
        TickersFetched (Ok s) ->
            ( { model
                | tickers = Just s
              }
            , Cmd.none
            )

        TickersFetched (Err s) ->
            Debug.log "TickersFetched Error" ( model, Cmd.none )

        FetchCharts s ->
            ( { model | selectedTicker = s }, fetchCharts s model )

        ChartsFetched (Ok s) ->
            let
                ciWin =
                    chartWindow s model
            in
                ( { model | chartInfo = Just s, chartInfoWin = Just ciWin }, drawChartInfo ciWin model )

        ChartsFetched (Err _) ->
            Debug.log "ChartsFetched err"
                ( model, Cmd.none )


drawChartInfo : ChartInfo -> Model -> Cmd Msg
drawChartInfo ci model =
    let
        strokes =
            [ "#000000", "#ff0000", "#aa00ff" ]

        infoJs =
            ChartInfoJs ci.xAxis ci.lines ci.candlesticks strokes
    in
        drawCanvas infoJs



------------------ COMMANDS -------------------


fetchTickers : Cmd Msg
fetchTickers =
    let
        url =
            mainUrl ++ "/tickers"
    in
        Http.send TickersFetched <|
            Http.get url comboBoxItemListDecoder


candlestickDecoder : Json.Decoder Candlestick
candlestickDecoder =
    Json.map4 Candlestick
        (Json.field "o" Json.float)
        (Json.field "h" Json.float)
        (Json.field "l" Json.float)
        (Json.field "c" Json.float)


fetchCharts : String -> Model -> Cmd Msg
fetchCharts ticker model =
    let
        myDecoder =
            JP.decode ChartInfo
                |> JP.required "min-dx" stringToDateDecoder
                |> JP.required "max-dx" stringToDateDecoder
                |> JP.optional "min-val" Json.float 0.0
                |> JP.optional "max-val" Json.float 0.0
                |> JP.required "x-axis" (Json.list Json.float)
                |> JP.required "lines" (Json.list (Json.list Json.float))
                |> JP.required "cndl" (Json.nullable (Json.list candlestickDecoder))

        url =
            if model.flags.isWeekly == True then
                mainUrl ++ "/tickerweek?oid=" ++ ticker
            else
                mainUrl ++ "/ticker?oid=" ++ ticker
    in
        Http.send ChartsFetched <| Http.get url myDecoder



---------------- SUBSCRIPTIONS ----------------


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
