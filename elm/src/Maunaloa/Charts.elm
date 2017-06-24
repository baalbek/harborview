port module Maunaloa.Charts exposing (..)

import Http
import Html as H
import Html.Attributes as A
import Common.Miscellaneous as M
import ChartCommon as C
import Common.ComboBox as CB
import Common.Buttons as BTN


mainUrl =
    "/maunaloa"


type alias Flags =
    { isWeekly : Bool
    }


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
   init : ( Model, Cmd Msg )
   init =
       ( initModel, fetchTickers )
-}


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initModel flags, fetchTickers )



------------------- MODEL ---------------------


type alias Model =
    { tickers : Maybe CB.SelectItems
    , selectedTicker : String
    , chartInfo : Maybe C.ChartInfo
    , chartInfoWin : Maybe C.ChartInfoJs
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
            [ CB.makeSelect "Tickers: " FetchCharts model.tickers model.selectedTicker
            ]
        , H.div [ A.class "row" ]
            [ button_ "Risc Lines" FetchRiscLines
            ]
        ]



------------------- UPDATE --------------------


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
            ( model, Cmd.none )

        ChartsFetched (Ok s) ->
            ( model, Cmd.none )

        ChartsFetched (Err s) ->
            Debug.log ("ChartsFetched Error: " ++ (M.httpErr2str s))
                ( model, Cmd.none )

        FetchRiscLines ->
            ( model, Cmd.none )

        RiscLinesFetched (Ok lx) ->
            ( model, Cmd.none )

        RiscLinesFetched (Err s) ->
            Debug.log ("RiscLinesFetched Error: " ++ (M.httpErr2str s)) ( model, Cmd.none )



------------------ COMMANDS -------------------


fetchTickers : Cmd Msg
fetchTickers =
    let
        url =
            mainUrl ++ "/tickers"
    in
        Http.send TickersFetched <|
            Http.get url CB.comboBoxItemListDecoder



---------------- SUBSCRIPTIONS ----------------


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
