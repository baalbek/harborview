module Maunaloa.Options exposing (..)

import Http
import Html as H
import Html.Attributes as A
import Json.Decode.Pipeline as JP
import Json.Decode as Json
import Html.Events as E
import Table exposing (defaultCustomizations)
import Common.Miscellaneous as MISC
import Common.ComboBox as CMB
import Common.Buttons as BTN


mainUrl =
    "/maunaloa"


type alias Flags =
    { isCalls : Bool
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
-------------------- INIT ---------------------


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initModel flags, fetchTickers )



------------------- MODEL ---------------------
-- {:dx "2017-3-31", :ticker "YAR7U240", :days 174.0, :buy 1.4, :sell 2.0, :iv-buy 0.313, :iv-sell 0.338}


type alias Stock =
    { date : String
    , time : String
    , opn : Float
    , hi : Float
    , lo : Float
    , spot : Float
    }


type alias Option =
    { ticker : String
    , days : Float
    , buy : Float
    , sell : Float
    , ivBuy : Float
    , ivSell : Float
    , breakEven : Float
    , selected : Bool
    }


type alias Options =
    List Option


type alias StockAndOptions =
    { stock : Stock
    , opx : Options
    }



{-
   type alias Stock =
       { dx : String
       }


   type alias StockWithOptions =
       { stock : Stock
       , options : List Option
       }

-}


type alias Model =
    { tickers : Maybe CMB.SelectItems
    , selectedTicker : String
    , stock : Maybe Stock
    , options : Maybe Options
    , risc : String
    , flags : Flags
    , tableState : Table.State
    }


initModel : Flags -> Model
initModel flags =
    { tickers = Nothing
    , selectedTicker = "-1"
    , stock = Nothing
    , options = Nothing
    , risc = "0.0"
    , flags = flags
    , tableState = Table.initialSort "Ticker"
    }



------------------- TABLE CONFIGURATION ---------------------


config : Table.Config Option Msg
config =
    Table.customConfig
        { toId = .ticker
        , toMsg = SetTableState
        , columns =
            [ checkboxColumn
            , Table.stringColumn "Ticker" .ticker
            , Table.floatColumn "Days" .days
            , Table.floatColumn "Buy" .buy
            , Table.floatColumn "Sell" .sell
            , Table.floatColumn "IvBuy" .ivBuy
            , Table.floatColumn "IvSell" .ivSell
            , Table.floatColumn "Break-Even" .breakEven
            , Table.floatColumn "Risc" (\x -> 0.0)
            ]
        , customizations =
            { defaultCustomizations | rowAttrs = toRowAttrs }
        }


toRowAttrs : Option -> List (H.Attribute Msg)
toRowAttrs opt =
    [ E.onClick (ToggleSelected opt.ticker)
    , A.style
        [ ( "background"
          , if opt.selected then
                "#CEFAF8"
            else
                "white"
          )
        ]
    ]


checkboxColumn : Table.Column Option Msg
checkboxColumn =
    Table.veryCustomColumn
        { name = ""
        , viewData = viewCheckbox
        , sorter = Table.unsortable
        }


viewCheckbox : Option -> Table.HtmlDetails Msg
viewCheckbox { selected } =
    Table.HtmlDetails []
        [ H.input [ A.type_ "checkbox", A.checked selected ] []
        ]



------------------- TYPES ---------------------


type Msg
    = TickersFetched (Result Http.Error CMB.SelectItems)
    | FetchOptions String
    | OptionsFetched (Result Http.Error StockAndOptions)
    | SetTableState Table.State
    | ResetCache
    | CalcRisc
    | RiscChange String
    | ToggleSelected String



-------------------- VIEW ---------------------


button_ =
    BTN.button "col-sm-2"


view : Model -> H.Html Msg
view model =
    let
        opx =
            Maybe.withDefault [] model.options

        stockInfo =
            case model.stock of
                Nothing ->
                    ""

                Just sx ->
                    -- "Spot: " ++ (toString sx.spot)
                    toString sx
    in
        H.div [ A.class "container" ]
            [ H.div [ A.class "row" ]
                [ H.div [ A.class "col-sm-3" ]
                    [ H.text stockInfo ]
                , button_ "Calc Risc" CalcRisc
                , H.div [ A.class "col-sm-2" ]
                    [ H.input [ A.placeholder "Risc", E.onInput RiscChange ] [] ]
                , button_ "Reset Cache" ResetCache
                , H.div [ A.class "col-sm-3" ]
                    [ CMB.makeSelect "Tickers: " FetchOptions model.tickers model.selectedTicker ]
                ]
            , H.div [ A.class "row" ]
                [ Table.view config model.tableState opx
                ]
            ]



------------------- UPDATE --------------------


update msg model =
    case msg of
        TickersFetched (Ok s) ->
            ( { model
                | tickers = Just s
              }
            , Cmd.none
            )

        TickersFetched (Err s) ->
            Debug.log ("TickersFetched Error: " ++ (MISC.httpErr2str s)) ( model, Cmd.none )

        FetchOptions s ->
            ( { model | selectedTicker = s }, fetchOptions model s False )

        OptionsFetched (Ok s) ->
            --Debug.log "OptionsFetched"
            ( { model | stock = Just s.stock, options = Just s.opx }, Cmd.none )

        OptionsFetched (Err s) ->
            Debug.log ("OptionsFetched Error: " ++ (MISC.httpErr2str s)) ( model, Cmd.none )

        SetTableState newState ->
            ( { model | tableState = newState }
            , Cmd.none
            )

        ResetCache ->
            ( model, fetchOptions model model.selectedTicker True )

        CalcRisc ->
            ( model, Cmd.none )

        RiscChange s ->
            --Debug.log "RiscChange"
            ( { model | risc = s }, Cmd.none )

        ToggleSelected ticker ->
            case model.options of
                Nothing ->
                    ( model, Cmd.none )

                Just optionx ->
                    ( { model | options = Just (List.map (toggle ticker) optionx) }
                    , Cmd.none
                    )


toggle : String -> Option -> Option
toggle ticker opt =
    if opt.ticker == ticker then
        { opt | selected = not opt.selected }
    else
        opt



------------------ COMMANDS ---------------------


calcRisc : Model -> Cmd Msg
calcRisc model =
    let
        opx =
            Maybe.withDefault [] model.options

        checked =
            List.filter (\x -> x.selected == True) opx
    in
        Cmd.none


optionDecoder : Json.Decoder Option
optionDecoder =
    JP.decode Option
        |> JP.required "ticker" Json.string
        |> JP.required "days" Json.float
        |> JP.required "buy" Json.float
        |> JP.required "sell" Json.float
        |> JP.required "iv-buy" Json.float
        |> JP.required "iv-sell" Json.float
        |> JP.required "br-even" Json.float
        |> JP.hardcoded False


stockDecoder : Json.Decoder Stock
stockDecoder =
    JP.decode Stock
        |> JP.required "dx" Json.string
        |> JP.required "tm" Json.string
        |> JP.required "opn" Json.float
        |> JP.required "hi" Json.float
        |> JP.required "lo" Json.float
        |> JP.required "spot" Json.float


fetchOptions : Model -> String -> Bool -> Cmd Msg
fetchOptions model s resetCache =
    let
        url =
            case model.flags.isCalls of
                True ->
                    case resetCache of
                        True ->
                            mainUrl ++ "/resetcalls?ticker=" ++ s

                        False ->
                            mainUrl ++ "/calls?ticker=" ++ s

                False ->
                    case resetCache of
                        True ->
                            mainUrl ++ "/resetputs?ticker=" ++ s

                        False ->
                            mainUrl ++ "/puts?ticker=" ++ s

        myDecoder =
            -- Json.list optionDecoder
            JP.decode StockAndOptions
                |> JP.required "stock" stockDecoder
                |> JP.required "options" (Json.list optionDecoder)
    in
        Http.send OptionsFetched <|
            Http.get url myDecoder


fetchTickers : Cmd Msg
fetchTickers =
    let
        url =
            mainUrl ++ "/tickers"
    in
        Http.send TickersFetched <|
            Http.get url CMB.comboBoxItemListDecoder



---------------- SUBSCRIPTIONS ----------------


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
