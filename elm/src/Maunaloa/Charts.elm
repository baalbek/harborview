port module Maunaloa.Charts exposing (..)

import Date exposing (toTime, Date)
import Time exposing (Time)
import Http
import Html as H
import Html.Attributes as A
import Json.Decode as Json
import Json.Decode.Pipeline as JP
import Common.Miscellaneous as M
import ChartCommon as C
import Common.ComboBox as CB
import Common.Buttons as BTN
import Common.DateUtil as DU


mainUrl =
    "/maunaloa"


type alias Flags =
    { isWeekly : Bool }


type alias Spot =
    { dx : Time
    , o : Float -- open
    , h : Float -- high
    , l : Float -- low
    , c : Float -- close
    }


type alias RiscLine =
    { ticker : String
    , be : Float
    , stockPrice : Float
    , optionPrice : Float
    , risc : Float
    , ask : Float
    }


type alias RiscLines =
    List RiscLine


type alias RiscLinesJs =
    { riscLines : RiscLines
    , valueRange : ( Float, Float )
    }


main : Program Flags Model Msg
main =
    H.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-------------------- PORTS ---------------------


port drawCanvas : C.ChartInfoJs -> Cmd msg


port drawRiscLines : RiscLinesJs -> Cmd msg


port drawSpot : Spot -> Cmd msg



-------------------- INIT ---------------------
{-
   init : ( Model, Cmd Msg)
   init =
       ( initModel, fetchTickers)
-}


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initModel flags, fetchTickers )



------------------- MODEL ---------------------
-- <editor-fold>


type alias Model =
    { tickers : Maybe CB.SelectItems
    , selectedTicker : String
    , chartInfo : Maybe C.ChartInfo
    , chartInfoWin : Maybe C.ChartInfoJs
    , riscLines : Maybe RiscLines
    , dropItems : Int
    , takeItems : Int
    , flags : Flags
    }


initModel : Flags -> Model
initModel flags =
    { tickers = Nothing
    , selectedTicker = "-1"
    , chartInfo = Nothing
    , chartInfoWin = Nothing
    , riscLines = Nothing
    , dropItems = 0
    , takeItems = 90
    , flags = flags
    }



-- </editor-fold>
------------------- TYPES ---------------------
--


type Msg
    = TickersFetched (Result Http.Error CB.SelectItems)
    | FetchCharts String
    | ChartsFetched (Result Http.Error C.ChartInfo)
    | FetchRiscLines
    | RiscLinesFetched (Result Http.Error RiscLines)
    | FetchSpot
    | SpotFetched (Result Http.Error Spot)
    | ResetCache



-------------------- VIEW ---------------------


button_ =
    BTN.button "col-sm-2"


view : Model -> H.Html Msg
view model =
    H.div [ A.class "container" ]
        [ H.div [ A.class "row" ]
            [ H.div [ A.class "col-sm-8" ] [ CB.makeSelect "Tickers: " FetchCharts model.tickers model.selectedTicker ]
            , button_ "Risc Lines" FetchRiscLines
            , button_ "Spot" FetchSpot
            , button_ "Reset Cache" ResetCache
            ]
        ]



------------------- UPDATE --------------------
-- <editor-fold>


slice : Model -> List a -> List a
slice model vals =
    List.take model.takeItems <| List.drop model.dropItems vals


chartValueRange :
    Maybe (List (List Float))
    -> Maybe (List (List Float))
    -> Maybe (List C.Candlestick)
    -> Float
    -> ( Float, Float )
chartValueRange lines bars candlesticks scaling =
    let
        minMaxLines =
            C.maybeMinMax lines

        minMaxBars =
            C.maybeMinMax bars

        minMaxCndl =
            C.minMaxCndl candlesticks

        result =
            minMaxCndl :: (minMaxLines ++ minMaxBars)
    in
        M.minMaxTuples result scaling


chartWindow : Model -> C.Chart -> Float -> C.Chart
chartWindow model c scaling =
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
            chartValueRange lines_ bars_ cndl_ scaling
    in
        C.Chart
            lines_
            bars_
            cndl_
            valueRange
            c.numVlines


chartInfoWindow : C.ChartInfo -> Model -> C.ChartInfoJs
chartInfoWindow ci model =
    let
        incMonths =
            case model.flags.isWeekly of
                True ->
                    3

                False ->
                    1

        xAxis_ =
            slice model ci.xAxis

        ( minDx_, maxDx_ ) =
            DU.dateRangeOf ci.minDx xAxis_

        strokes =
            [ "#000000", "#ff0000", "#aa00ff" ]

        chw =
            chartWindow model ci.chart 1.05

        chw2 =
            case ci.chart2 of
                Nothing ->
                    Nothing

                Just c2 ->
                    Just (chartWindow model c2 1.0)

        chw3 =
            case ci.chart3 of
                Nothing ->
                    Nothing

                Just c3 ->
                    Just (chartWindow model c3 1.0)
    in
        C.ChartInfoJs
            (toTime minDx_)
            xAxis_
            chw
            chw2
            chw3
            strokes
            incMonths


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TickersFetched (Ok s) ->
            ( { model
                | tickers = Just s
              }
            , Cmd.none
            )

        TickersFetched (Err s) ->
            Debug.log ("TickersFetched Error: " ++ (M.httpErr2str s)) ( model, Cmd.none )

        FetchCharts s ->
            ( { model | selectedTicker = s }, fetchCharts s model False )

        ChartsFetched (Ok s) ->
            let
                ciWin =
                    chartInfoWindow s model
            in
                ( { model
                    | chartInfo = Just s
                    , chartInfoWin = Just ciWin
                  }
                , drawCanvas ciWin
                )

        ChartsFetched (Err s) ->
            Debug.log ("ChartsFetched Error: " ++ (M.httpErr2str s))
                ( model, Cmd.none )

        FetchRiscLines ->
            ( model, fetchRiscLines model )

        RiscLinesFetched (Ok lx) ->
            case
                model.chartInfoWin
            of
                Just ciWin ->
                    let
                        riscLinesJs =
                            RiscLinesJs lx ciWin.chart.valueRange
                    in
                        ( { model | riscLines = Just lx }, drawRiscLines riscLinesJs )

                Nothing ->
                    ( { model | riscLines = Just lx }, Cmd.none )

        RiscLinesFetched (Err s) ->
            Debug.log ("RiscLinesFetched Error: " ++ (M.httpErr2str s)) ( model, Cmd.none )

        FetchSpot ->
            ( model, fetchSpot model )

        SpotFetched (Ok s) ->
            Debug.log (toString s)
                ( model, drawSpot s )

        -- ( model, drawSpot s )
        SpotFetched (Err s) ->
            Debug.log ("SpotFetched Error: " ++ (M.httpErr2str s)) ( model, Cmd.none )

        ResetCache ->
            ( model, fetchCharts model.selectedTicker model True )



-- </editor-fold>
------------------ COMMANDS -------------------
-- <editor-fold>


fetchSpot : Model -> Cmd Msg
fetchSpot model =
    let
        url =
            mainUrl ++ "/spot?ticker=" ++ model.selectedTicker

        spotDecoder =
            JP.decode Spot
                |> JP.required "dx" M.stringToTimeDecoder
                |> JP.required "o" Json.float
                |> JP.required "h" Json.float
                |> JP.required "l" Json.float
                |> JP.required "c" Json.float
    in
        Http.send SpotFetched <|
            Http.get url spotDecoder


fetchRiscLines : Model -> Cmd Msg
fetchRiscLines model =
    let
        url =
            mainUrl ++ "/risclines?ticker=" ++ model.selectedTicker

        riscDecoder =
            JP.decode RiscLine
                |> JP.required "ticker" Json.string
                |> JP.required "be" Json.float
                |> JP.required "stockprice" Json.float
                |> JP.required "optionprice" Json.float
                |> JP.required "risc" Json.float
                |> JP.required "ask" Json.float
    in
        Http.send RiscLinesFetched <|
            Http.get url (Json.list riscDecoder)


fetchTickers : Cmd Msg
fetchTickers =
    let
        url =
            mainUrl ++ "/tickers"
    in
        Http.send TickersFetched <|
            Http.get url CB.comboBoxItemListDecoder


candlestickDecoder : Json.Decoder C.Candlestick
candlestickDecoder =
    Json.map4 C.Candlestick
        (Json.field "o" Json.float)
        (Json.field "h" Json.float)
        (Json.field "l" Json.float)
        (Json.field "c" Json.float)


chartDecoder : Int -> Json.Decoder C.Chart
chartDecoder numVlines =
    let
        lines =
            (Json.field "lines" (Json.maybe (Json.list (Json.list Json.float))))

        bars =
            (Json.field "bars" (Json.maybe (Json.list (Json.list Json.float))))

        candlesticks =
            (Json.field "cndl" (Json.maybe (Json.list candlestickDecoder)))
    in
        Json.map5 C.Chart lines bars candlesticks (Json.succeed ( 0, 0 )) (Json.succeed numVlines)


fetchCharts : String -> Model -> Bool -> Cmd Msg
fetchCharts ticker model resetCache =
    let
        myDecoder =
            JP.decode C.ChartInfo
                |> JP.required "min-dx" M.stringToDateDecoder
                |> JP.required "x-axis" (Json.list Json.float)
                |> JP.required "chart" (chartDecoder 10)
                |> JP.required "chart2" (Json.nullable (chartDecoder 5))
                |> JP.required "chart3" (Json.nullable (chartDecoder 5))

        url =
            case resetCache of
                True ->
                    if model.flags.isWeekly == True then
                        mainUrl ++ "/resettickerweek?oid=" ++ ticker
                    else
                        mainUrl ++ "/resetticker?oid=" ++ ticker

                False ->
                    if model.flags.isWeekly == True then
                        mainUrl ++ "/tickerweek?oid=" ++ ticker
                    else
                        mainUrl ++ "/ticker?oid=" ++ ticker
    in
        Http.send ChartsFetched <| Http.get url myDecoder



-- </editor-fold>
---------------- SUBSCRIPTIONS ----------------


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
