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
import ChartCommon as C exposing (Candlestick, ChartInfo, ChartLines, ChartInfoJs)


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
    , minDx : Date
    , maxDx : Date
    , chartInfo : Maybe ChartInfo
    , chartInfoWin : Maybe ChartInfoJs
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
    , minDx = Date.fromTime 0
    , maxDx = Date.fromTime 0
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

        ( vruler, hruler, hruler2, vruler2 ) =
            case model.chartInfoWin of
                Nothing ->
                    ( [], [], [], [] )

                Just ci ->
                    let
                        vruler_ =
                            VR.lines w model.chartHeight 10 ci.chartLines

                        hruler_ =
                            HR.lines w model.chartHeight model.minDx model.maxDx
                    in
                        ( vruler_, hruler_, [], [] )
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


chartWindowLines : (a -> List Float) -> List a -> Float -> ( ChartLines, Float -> Float )
chartWindowLines valueFn lines chartHeight =
    let
        lines_ =
            List.map valueFn lines

        valueRange =
            List.map VR.minMax lines_ |> M.minMaxTuples

        vr =
            VR.vruler valueRange chartHeight
    in
        ( ChartLines
            (TUP.first valueRange)
            (TUP.second valueRange)
            (List.map (List.map vr) lines_)
        , vr
        )


chartWindow : ChartInfo -> Model -> ( ChartInfoJs, Date, Date )
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

        ( lines1_, vr1 ) =
            chartWindowLines valueFn ci.lines model.chartHeight

        lines2_ =
            case ci.lines2 of
                Nothing ->
                    Nothing

                Just lx2 ->
                    let
                        ( lx2_, _ ) =
                            chartWindowLines valueFn lx2 model.chartHeight2
                    in
                        Just lx2_

        cndl_ =
            case ci.candlesticks of
                Nothing ->
                    Nothing

                Just cs ->
                    let
                        vr_cndl =
                            scaledCandlestick vr1

                        my_cndls =
                            valueFn cs
                    in
                        Just (List.map vr_cndl my_cndls)

        strokes =
            [ "#000000", "#ff0000", "#aa00ff" ]
    in
        ( C.ChartInfoJs
            (List.map hr xAxis_)
            lines1_
            cndl_
            lines2_
            strokes
        , minDx_
        , maxDx_
        )


httpErr2str : Http.Error -> String
httpErr2str err =
    case err of
        Http.Timeout ->
            "Timeout"

        Http.NetworkError ->
            "NetworkError"

        Http.BadUrl s ->
            "BadUrl: " ++ s

        Http.BadStatus r ->
            "BadStatus: "

        Http.BadPayload s r ->
            "BadPayload: " ++ s


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
            Debug.log ("TickersFetched Error: " ++ (httpErr2str s)) ( model, Cmd.none )

        FetchCharts s ->
            ( { model | selectedTicker = s }, fetchCharts s model )

        ChartsFetched (Ok s) ->
            let
                ( ciWin, minDx, maxDx ) =
                    chartWindow s model
            in
                ( { model
                    | chartInfo = Just s
                    , chartInfoWin = Just ciWin
                    , minDx = minDx
                    , maxDx = maxDx
                  }
                , drawCanvas ciWin
                )

        ChartsFetched (Err _) ->
            Debug.log "ChartsFetched err"
                ( model, Cmd.none )



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
                |> JP.required "x-axis" (Json.list Json.float)
                |> JP.required "lines" (Json.list (Json.list Json.float))
                |> JP.required "cndl" (Json.nullable (Json.list candlestickDecoder))
                |> JP.required "lines2" (Json.nullable (Json.list (Json.list Json.float)))

        -- |> JP.hardcoded Nothing
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
