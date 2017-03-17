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
import Date exposing (toTime)


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
import ChartCommon as C exposing (Candlestick, ChartInfo, ChartInfoJs, Chart)


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
    , chartInfoWin : Maybe ChartInfoJs
    , dropItems : Int
    , takeItems : Int
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
    H.div [ A.class "container" ]
        [ H.div [ A.class "row" ]
            [ makeSelect "Tickers: " FetchCharts model.tickers model.selectedTicker
            ]
        ]



{-
   view : Model -> H.Html Msg
   view model =
       let
           w =
               model.chartWidth

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
                               VR.lines w 10 ci.chart

                           hruler_ =
                               HR.lines w model.chartHeight model.minDx model.maxDx

                           vruler2_ =
                               case ci.chart2 of
                                   Nothing ->
                                       []

                                   Just chart2 ->
                                       VR.lines w 5 chart2

                           hruler2_ =
                               case ci.chart2 of
                                   Nothing ->
                                       []

                                   Just chart2 ->
                                       HR.lines w model.chartHeight2 model.minDx model.maxDx
                       in
                           ( vruler_, hruler_, vruler2_, hruler2_ )
       in
           H.div [ A.class "container" ]
               [ H.div [ A.class "row" ]
                   [ makeSelect "Tickers: " FetchCharts model.tickers model.selectedTicker
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
-}
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



{-
   testChart : Chart
   testChart =
       let
           lines =
               Just
                   [ [ 23, 24, 21, 23, 11, 12 ] ]

           bars =
               Just
                   [ [ 23, 24, 21, 23, 11, 12 ]
                   , [ 232, 24, 21, 23, 11, 12 ]
                   , [ -23, 24, 21, 23, 11, 12 ]
                   ]

           candlesticks =
               Just [ Candlestick 100 1202 90 97 ]
       in
           Chart lines bars candlesticks 1000 ( 0, 0 )
-}


slice : Model -> List a -> List a
slice model vals =
    List.take model.takeItems <| List.drop model.dropItems vals


chartValueRange :
    Maybe (List (List Float))
    -> Maybe (List (List Float))
    -> Maybe (List Candlestick)
    -> ( Float, Float )
chartValueRange lines bars candlesticks =
    let
        minMaxLines =
            VR.maybeMinMax lines

        minMaxBars =
            VR.maybeMinMax bars

        minMaxCndl =
            VR.minMaxCndl candlesticks

        result =
            minMaxCndl :: (minMaxLines ++ minMaxBars)
    in
        M.minMaxTuples result


chartWindow : Model -> Chart -> Chart
chartWindow model c =
    let
        sliceFn =
            slice model

        lines_ =
            case c.lines of
                Nothing ->
                    Nothing

                Just l ->
                    Just (List.map sliceFn l)

        bars_ =
            case c.bars of
                Nothing ->
                    Nothing

                Just b ->
                    Just (List.map sliceFn b)

        cndl_ =
            case c.candlesticks of
                Nothing ->
                    Nothing

                Just cndl ->
                    Just (sliceFn cndl)

        valueRange =
            chartValueRange lines_ bars_ cndl_

        vr =
            VR.vruler valueRange c.height

        vr_cndl =
            scaledCandlestick vr
    in
        Chart
            (M.maybeMap (List.map vr) lines_)
            (M.maybeMap (List.map vr) bars_)
            (M.maybeMap vr_cndl cndl_)
            c.height
            valueRange


chartInfoWindow : ChartInfo -> Model -> ChartInfoJs
chartInfoWindow ci model =
    let
        xAxis_ =
            slice model ci.xAxis

        ( minDx_, maxDx_ ) =
            HR.dateRangeOf ci.minDx xAxis_

        {-
           hr =
               HR.hruler minDx_ maxDx_ xAxis_ model.chartWidth

        -}
        strokes =
            [ "#000000", "#ff0000", "#aa00ff" ]

        chw =
            chartWindow model ci.chart

        chw2 =
            case ci.chart2 of
                Nothing ->
                    Nothing

                Just c2 ->
                    Just (chartWindow model c2)
    in
        ChartInfoJs
            (toTime minDx_)
            xAxis_
            chw
            chw2
            strokes


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
                ciWin =
                    chartInfoWindow s model
            in
                Debug.log "ChartsFetched"
                    ( { model
                        | chartInfo = Just s
                        , chartInfoWin = Just ciWin
                      }
                    , drawCanvas ciWin
                    )

        ChartsFetched (Err s) ->
            Debug.log ("ChartsFetched Error: " ++ (httpErr2str s))
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


chartDecoder : Float -> Json.Decoder Chart
chartDecoder chartHeight =
    let
        lines =
            (Json.field "lines" (Json.maybe (Json.list (Json.list Json.float))))

        bars =
            (Json.field "bars" (Json.maybe (Json.list (Json.list Json.float))))

        candlesticks =
            (Json.field "cndl" (Json.maybe (Json.list candlestickDecoder)))
    in
        Json.map5 Chart lines bars candlesticks (Json.succeed chartHeight) (Json.succeed ( 0, 0 ))


fetchCharts : String -> Model -> Cmd Msg
fetchCharts ticker model =
    let
        myDecoder =
            JP.decode ChartInfo
                |> JP.required "min-dx" stringToDateDecoder
                |> JP.required "x-axis" (Json.list Json.float)
                |> JP.required "chart" (chartDecoder model.chartHeight)
                |> JP.required "chart2" (Json.nullable (chartDecoder model.chartHeight2))

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
