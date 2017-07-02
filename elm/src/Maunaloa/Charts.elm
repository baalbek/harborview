port module Maunaloa.Charts exposing (..)

import Date exposing (toTime)
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


type alias RiscLine =
    { ticker : String
    , be : Float
    , risc : Float
    , optionPrice : Float
    }


type alias RiscLines =
    List RiscLine


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
    , riscLines = Nothing
    , dropItems = 0
    , takeItems = 90
    , chartHeight = 600
    , chartHeight2 = 300
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



-------------------- VIEW ---------------------


button_ =
    BTN.button "col-sm-2"


view : Model -> H.Html Msg
view model =
    H.div [ A.class "container" ]
        [ H.div [ A.class "row" ]
            [ CB.makeSelect "Tickers: " FetchCharts model.tickers model.selectedTicker ]
        , H.div [ A.class "row" ]
            [ button_ "Risc Lines" FetchRiscLines ]
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
    -> ( Float, Float )
chartValueRange lines bars candlesticks =
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
        M.minMaxTuples result


chartWindow : Model -> C.Chart -> C.Chart
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
            chartWindow model ci.chart

        chw2 =
            case ci.chart2 of
                Nothing ->
                    Nothing

                Just c2 ->
                    Just (chartWindow model c2)
    in
        C.ChartInfoJs
            (toTime minDx_)
            xAxis_
            chw
            chw2
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
            ( { model | selectedTicker = s }, fetchCharts s model )

        ChartsFetched (Ok s) ->
            let
                ciWin =
                    chartInfoWindow s model
            in
                Debug.log "ChartsFetched:"
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
            ( { model | riscLines = Just lx }, Cmd.none )

        RiscLinesFetched (Err s) ->
            Debug.log ("RiscLinesFetched Error: " ++ (M.httpErr2str s)) ( model, Cmd.none )



-- </editor-fold>
------------------ COMMANDS -------------------
-- <editor-fold>


fetchRiscLines : Model -> Cmd Msg
fetchRiscLines model =
    let
        url =
            mainUrl ++ "/risclines?ticker=" ++ model.selectedTicker

        riscDecoder =
            JP.decode RiscLine
                |> JP.required "ticker" Json.string
                |> JP.required "be" Json.float
                |> JP.required "risc" Json.float
                |> JP.required "option-price" Json.float
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


fetchCharts : String -> Model -> Cmd Msg
fetchCharts ticker model =
    let
        myDecoder =
            JP.decode C.ChartInfo
                |> JP.required "min-dx" M.stringToDateDecoder
                |> JP.required "x-axis" (Json.list Json.float)
                |> JP.required "chart" (chartDecoder 10)
                |> JP.required "chart2" (Json.nullable (chartDecoder 5))

        -- |> JP.hardcoded Nothing
        url =
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
