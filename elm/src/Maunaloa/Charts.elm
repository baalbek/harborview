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
import Common.ModalDialog as DLG


mainUrl =
    "/maunaloa"


days =
    1


weeks =
    2


months =
    3


type alias Flags =
    { chartResolution : Int }


type alias Spot =
    { dx : Time
    , tm : String
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


type alias OptionPurchase =
    { oid : Int
    , ticker : String
    , purchaseDate : String
    , volume : Int
    , purchasePrice : Float
    , ivAtPurchase : Maybe Float
    , bid : Float
    , ask : Float
    , iv : Maybe Float
    , spot : Float
    }


type alias OptionPurchases =
    List OptionPurchase


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


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initModel flags, fetchTickers )



------------------- MODEL ---------------------


type alias Model =
    { tickers : Maybe CB.SelectItems
    , selectedTicker : String
    , chartInfo : Maybe C.ChartInfo
    , chartInfoWin : Maybe C.ChartInfoJs
    , riscLines : Maybe RiscLines
    , dropItems : Int
    , takeItems : Int
    , flags : Flags
    , dlgOptions : DLG.DialogState
    , optionPurchases : Maybe OptionPurchases
    , isResetCache : Bool
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
    , dlgOptions = DLG.DialogHidden
    , optionPurchases = Nothing
    , isResetCache = False
    }



------------------- TYPES ---------------------


type Msg
    = TickersFetched (Result Http.Error CB.SelectItems)
    | FetchCharts String
    | ChartsFetched (Result Http.Error C.ChartInfo)
    | FetchRiscLines
    | RiscLinesFetched (Result Http.Error RiscLines)
    | FetchSpot
    | SpotFetched (Result Http.Error Spot)
    | ToggleResetCache
    | OptionsDlgOk
    | OptionsDlgCancel



-------------------- VIEW ---------------------


button_ =
    BTN.button "col-sm-2"


optionTabs =
    3


view : Model -> H.Html Msg
view model =
    let
        row =
            case model.flags.chartResolution of
                1 ->
                    [ H.div [ A.class "col-sm-4" ] [ CB.makeSelect "Tickers: " FetchCharts model.tickers model.selectedTicker ]
                    , button_ "Risc Lines" FetchRiscLines
                    , button_ "Spot" FetchSpot
                    , M.checkbox "Reset Cache" "col-sm-2 checkbox" False ToggleResetCache
                    ]

                2 ->
                    [ H.div [ A.class "col-sm-8" ] [ CB.makeSelect "Tickers: " FetchCharts model.tickers model.selectedTicker ]
                    , button_ "Risc Lines" FetchRiscLines
                    ]

                _ ->
                    [ H.div [ A.class "col-sm-8" ] [ CB.makeSelect "Tickers: " FetchCharts model.tickers model.selectedTicker ]
                    , button_ "Risc Lines" FetchRiscLines
                    ]
    in
        H.div [ A.class "container" ]
            [ H.div [ A.class "row" ]
                row
            , DLG.modalDialog "Optionpurchases"
                model.dlgOptions
                OptionsDlgOk
                OptionsDlgCancel
                []
            ]



------------------- UPDATE --------------------


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


normalizeLine : List Float -> List Float
normalizeLine line =
    let
        ( mi, ma ) =
            C.minMaxWithDefault line -1.0 1.0

        scalingFactor =
            max (abs mi) ma

        scalingFunction x =
            x / scalingFactor
    in
        List.map scalingFunction line


normalizeLines : List (List Float) -> List (List Float)
normalizeLines lines =
    List.map normalizeLine lines


chartWindow : Model -> C.Chart -> Float -> Bool -> C.Chart
chartWindow model c scaling doNormalizeLines =
    let
        sliceFn =
            slice model

        lines_ =
            case c.lines of
                Nothing ->
                    Nothing

                Just l ->
                    case doNormalizeLines of
                        True ->
                            let
                                normalized =
                                    normalizeLines (List.map sliceFn l)
                            in
                                Just normalized

                        False ->
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
            case model.flags.chartResolution of
                2 ->
                    3

                3 ->
                    6

                _ ->
                    1

        xAxis_ =
            slice model ci.xAxis

        ( minDx_, maxDx_ ) =
            DU.dateRangeOf ci.minDx xAxis_

        strokes =
            [ "#000000", "#ff0000", "#aa00ff" ]

        chw =
            chartWindow model ci.chart 1.05 False

        chw2 =
            case ci.chart2 of
                Nothing ->
                    Nothing

                Just c2 ->
                    Just (chartWindow model c2 1.0 True)

        chw3 =
            case ci.chart3 of
                Nothing ->
                    Nothing

                Just c3 ->
                    Just (chartWindow model c3 1.0 False)
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
            ( { model | selectedTicker = s }, fetchCharts s model.flags.chartResolution model.isResetCache )

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
            ( model, fetchSpot model.selectedTicker model.isResetCache )

        SpotFetched (Ok s) ->
            ( model, drawSpot s )

        -- ( model, drawSpot s )
        SpotFetched (Err s) ->
            Debug.log ("SpotFetched Error: " ++ (M.httpErr2str s)) ( model, Cmd.none )

        --ResetCache ->
        --   ( model, fetchCharts model.selectedTicker model True )
        OptionsDlgOk ->
            ( { model | dlgOptions = DLG.DialogHidden }, Cmd.none )

        OptionsDlgCancel ->
            ( { model | dlgOptions = DLG.DialogHidden }, Cmd.none )

        ToggleResetCache ->
            let
                checked =
                    not model.isResetCache
            in
                ( { model | isResetCache = checked }, Cmd.none )



------------------ COMMANDS -------------------


resetCacheJson : Bool -> String
resetCacheJson resetCache =
    case resetCache of
        True ->
            "&rc=1"

        False ->
            "&rc=0"


fetchSpot : String -> Bool -> Cmd Msg
fetchSpot selectedTicker resetCache =
    let
        url =
            mainUrl ++ "/spot?ticker=" ++ selectedTicker ++ (resetCacheJson resetCache)

        spotDecoder =
            JP.decode Spot
                |> JP.required "dx" M.stringToTimeDecoder
                |> JP.required "tm" Json.string
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


fetchCharts : String -> Int -> Bool -> Cmd Msg
fetchCharts ticker chartResolution resetCache =
    let
        --rc =
        --   resetCacheJson resetCache
        myDecoder =
            JP.decode C.ChartInfo
                |> JP.required "min-dx" M.stringToDateDecoder
                |> JP.required "x-axis" (Json.list Json.float)
                |> JP.required "chart" (chartDecoder 10)
                |> JP.required "chart2" (Json.nullable (chartDecoder 5))
                |> JP.required "chart3" (Json.nullable (chartDecoder 5))

        url =
            case chartResolution of
                1 ->
                    mainUrl ++ "/ticker?oid=" ++ ticker ++ (resetCacheJson resetCache)

                2 ->
                    mainUrl ++ "/tickerweek?oid=" ++ ticker ++ (resetCacheJson resetCache)

                _ ->
                    mainUrl ++ "/tickermonth?oid=" ++ ticker ++ (resetCacheJson resetCache)
    in
        Http.send ChartsFetched <| Http.get url myDecoder



---------------- SUBSCRIPTIONS ----------------


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
