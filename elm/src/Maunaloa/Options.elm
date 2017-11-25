module Maunaloa.Options exposing (..)

import Dict exposing (Dict, fromList)
import Http
import Html as H
import Html.Attributes as A
import Json.Decode.Pipeline as JP
import Json.Decode as Json
import Json.Encode as JE
import Html.Events as E
import Table exposing (defaultCustomizations)
import Common.Miscellaneous as M
import Common.ComboBox as CMB
import Common.Buttons as BTN
import Common.ModalDialog as DLG exposing (errorAlert)


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
        , subscriptions = \_ -> Sub.none
        }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initModel flags, fetchTickers )



------------------- MODEL ---------------------
-- {:dx "2017-3-31", :ticker "YAR7U240", :days 174.0, :buy 1.4, :sell 2.0, :iv-buy 0.313, :iv-sell 0.338}
-- #region TYPES


type alias Stock =
    { date : String
    , time : String
    , o : Float
    , h : Float
    , l : Float
    , c : Float
    }


type alias Option =
    { ticker : String
    , x : Float
    , days : Float
    , buy : Float
    , sell : Float
    , ivBuy : Float
    , ivSell : Float
    , breakEven : Float
    , spread : Float
    , risc : Float
    , optionPriceAtRisc : Float
    , stockPriceAtRisc : Float
    , selected : Bool
    }


type alias Options =
    List Option


type alias StockAndOptions =
    { stock : Stock
    , opx : Options
    }


type alias RiscItem =
    { ticker : String
    , risc : Float
    }


type alias RiscItems =
    List RiscItem


type alias OptionSale =
    {}



{- }
   type alias OptionPurchaseWithSale =
       { oid : Int
       , ticker : String
       , purchaseDate : String
       , price : Float
       , spot : Float
       }


   type alias OptionPurchases =
       List OptionPurchaseWithSale

-}


type alias PurchaseStatus =
    { ok : Bool, msg : String }


type Msg
    = AlertOk
    | TickersFetched (Result Http.Error CMB.SelectItems)
    | FetchOptions String
    | OptionsFetched (Result Http.Error StockAndOptions)
    | SetTableState Table.State
    | ResetCache
    | CalcRisc
    | RiscCalculated (Result Http.Error RiscItems)
    | RiscChange String
    | ToggleSelected String
    | PurchaseClick Option
    | PurchaseDlgOk
    | PurchaseDlgCancel
    | OptionPurchased (Result Http.Error PurchaseStatus)
    | ToggleRealTimePurchase
    | AskChange String
    | BidChange String
    | VolumeChange String
    | SpotChange String



-- | FetchPurchases
-- | PurchasesFetched (Result Http.Error OptionPurchases)
-- | ToggleRealTimePurchase


type alias Model =
    { tickers : Maybe CMB.SelectItems
    , selectedTicker : String
    , stock : Maybe Stock
    , options : Maybe Options
    , risc : String
    , flags : Flags
    , tableState : Table.State
    , dlgPurchase : DLG.DialogState
    , dlgAlert : DLG.DialogState
    , selectedPurchase : Maybe Option
    , isRealTimePurchase : Bool
    , ask : String
    , bid : String
    , volume : String
    , spot : String
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
    , dlgPurchase = DLG.DialogHidden
    , dlgAlert = DLG.DialogHidden
    , selectedPurchase = Nothing
    , isRealTimePurchase = True
    , ask = "0.0"
    , bid = "0.0"
    , volume = "10"
    , spot = "0.0"
    }



-- #endregion
-- #region VIEW


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
                    toString sx

        dlgHeader =
            case model.selectedPurchase of
                Nothing ->
                    "Option Purchase"

                Just sp ->
                    "Option Purchase " ++ sp.ticker
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
            , DLG.modalDialog dlgHeader
                model.dlgPurchase
                PurchaseDlgOk
                PurchaseDlgCancel
                [ H.div [ A.class "form-group row" ]
                    [ H.input [ A.checked True, A.type_ "checkbox", E.onClick ToggleRealTimePurchase ] []
                    , H.text "Real-time purchase"
                    ]
                , M.makeFGRInput AskChange "id1" "Ask:" "number" M.CX39 model.ask
                , M.makeFGRInput BidChange "id2" "Bid:" "number" M.CX39 model.bid
                , M.makeFGRInput VolumeChange "id3" "Volume:" "number" M.CX39 model.volume
                , M.makeFGRInput SpotChange "id4" "Spot:" "number" M.CX39 model.spot
                ]
            , DLG.alert model.dlgAlert AlertOk
            ]



-- #endregion
-- #region TABLE CONFIGURATION


config : Table.Config Option Msg
config =
    Table.customConfig
        { toId = .ticker
        , toMsg = SetTableState
        , columns =
            [ checkboxColumn
            , buttonColumn
            , Table.stringColumn "Ticker" .ticker
            , Table.floatColumn "Exercise" .x
            , Table.floatColumn "Days" .days
            , Table.floatColumn "Buy" .buy
            , Table.floatColumn "Sell" .sell
            , Table.floatColumn "Spread" .spread
            , Table.floatColumn "IvBuy" .ivBuy
            , Table.floatColumn "IvSell" .ivSell
            , Table.floatColumn "Break-Even" .breakEven
            , Table.floatColumn "Risc" .risc
            , Table.floatColumn "O.P. at Risc" .optionPriceAtRisc
            , Table.floatColumn "S.P. at Risc" .stockPriceAtRisc
            ]
        , customizations =
            { defaultCustomizations | rowAttrs = toRowAttrs }
        }


toRowAttrs : Option -> List (H.Attribute Msg)
toRowAttrs opt =
    [ -- E.onClick (ToggleSelected opt.ticker)
      A.style
        [ ( "background"
          , if opt.selected then
                "#FFCC99"
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
viewCheckbox { selected, ticker } =
    Table.HtmlDetails []
        [ H.input [ A.type_ "checkbox", A.checked selected, E.onClick (ToggleSelected ticker) ] []
        ]


buttonColumn : Table.Column Option Msg
buttonColumn =
    Table.veryCustomColumn
        { name = "Purchase"
        , viewData = tableButton
        , sorter = Table.unsortable
        }


tableButton : Option -> Table.HtmlDetails Msg
tableButton opt =
    Table.HtmlDetails []
        [ H.button [ A.class "btn btn-success", E.onClick (PurchaseClick opt) ] [ H.text "Buy" ]
        ]



-- #endregion
-- #region UPDATE
{-

   type alias Alertable a =
       { a | dlgAlert : DLG.DialogState }


   errorAlert : String -> String -> Http.Error -> Alertable a -> Alertable a
   errorAlert title errMsg httpErr model =
       let
           errStr =
               errMsg ++ (M.httpErr2str httpErr)
       in
           { model | dlgAlert = DLG.DialogVisibleAlert title errStr DLG.Error }
-}


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AlertOk ->
            ( { model | dlgAlert = DLG.DialogHidden }, Cmd.none )

        TickersFetched (Ok s) ->
            ( { model
                | tickers = Just s
              }
            , Cmd.none
            )

        TickersFetched (Err s) ->
            ( errorAlert "Error" "TickersFetched Error: " s model, Cmd.none )

        FetchOptions s ->
            ( { model | selectedTicker = s }, fetchOptions model s False )

        OptionsFetched (Ok s) ->
            ( { model | stock = Just s.stock, options = Just s.opx }, Cmd.none )

        OptionsFetched (Err s) ->
            ( errorAlert "Error" "OptionsFetched Error: " s model, Cmd.none )

        SetTableState newState ->
            ( { model | tableState = newState }
            , Cmd.none
            )

        ResetCache ->
            ( model, fetchOptions model model.selectedTicker True )

        CalcRisc ->
            ( model, calcRisc model.risc model.options )

        RiscCalculated (Ok s) ->
            case model.options of
                Nothing ->
                    ( model, Cmd.none )

                Just optionx ->
                    let
                        curRisc =
                            Result.withDefault 0 (String.toFloat model.risc)
                    in
                        ( { model | options = Just (List.map (setRisc curRisc s) optionx) }, Cmd.none )

        RiscCalculated (Err s) ->
            ( errorAlert "RiscCalculated" "RiscCalculated Error: " s model, Cmd.none )

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

        PurchaseClick opt ->
            let
                curSpot =
                    M.unpackMaybe model.stock .c 0

                -- Maybe.withDefault 0 <| Maybe.map .c model.stock
            in
                ( { model
                    | dlgPurchase = DLG.DialogVisible
                    , selectedPurchase = Just opt
                    , ask = toString opt.sell
                    , bid = toString opt.buy
                    , volume = "10"
                    , spot = toString curSpot
                  }
                , Cmd.none
                )

        PurchaseDlgOk ->
            case model.selectedPurchase of
                Just opx ->
                    let
                        curAsk =
                            Result.withDefault -1 (String.toFloat model.ask)

                        curBid =
                            Result.withDefault -1 (String.toFloat model.bid)

                        curVol =
                            Result.withDefault -1 (String.toInt model.volume)

                        curSpot =
                            Result.withDefault -1 (String.toFloat model.spot)
                    in
                        ( { model | dlgPurchase = DLG.DialogHidden }
                        , purchaseOption opx.ticker curAsk curBid curVol curSpot model.isRealTimePurchase
                        )

                Nothing ->
                    ( { model | dlgPurchase = DLG.DialogHidden }, Cmd.none )

        PurchaseDlgCancel ->
            ( { model | dlgPurchase = DLG.DialogHidden }, Cmd.none )

        OptionPurchased (Ok s) ->
            let
                alertCat =
                    case s.ok of
                        True ->
                            DLG.Info

                        False ->
                            DLG.Error
            in
                ( { model | dlgAlert = DLG.DialogVisibleAlert "Option purchase" s.msg alertCat }, Cmd.none )

        OptionPurchased (Err s) ->
            Debug.log "OptionPurchased ERR"
                ( errorAlert "Purchase Sale ERROR!" "SaleOk Error: " s model, Cmd.none )

        ToggleRealTimePurchase ->
            let
                checked =
                    not model.isRealTimePurchase
            in
                ( { model | isRealTimePurchase = checked }, Cmd.none )

        AskChange s ->
            ( { model | ask = s }, Cmd.none )

        BidChange s ->
            ( { model | bid = s }, Cmd.none )

        VolumeChange s ->
            ( { model | volume = s }, Cmd.none )

        SpotChange s ->
            ( { model | spot = s }, Cmd.none )



-- #endregion
-- #region COMMANDS


purchaseOption : String -> Float -> Float -> Int -> Float -> Bool -> Cmd Msg
purchaseOption ticker ask bid volume spot isRealTime =
    let
        url =
            mainUrl ++ "/purchaseoption"

        params =
            [ ( "ticker", JE.string ticker )
            , ( "ask", JE.float ask )
            , ( "bid", JE.float bid )
            , ( "vol", JE.int volume )
            , ( "spot", JE.float spot )
            , ( "rt", JE.bool isRealTime )
            ]

        jbody =
            M.asHttpBody params

        myDecoder =
            JP.decode PurchaseStatus
                |> JP.required "ok" Json.bool
                |> JP.required "msg" Json.string
    in
        Http.send OptionPurchased <|
            Http.post url jbody myDecoder


toggle : String -> Option -> Option
toggle ticker opt =
    if opt.ticker == ticker then
        { opt | selected = not opt.selected }
    else
        opt


setRisc : Float -> RiscItems -> Option -> Option
setRisc curRisc riscItems opt =
    let
        predicate =
            \x -> x.ticker == opt.ticker

        curRiscItem =
            M.findInList predicate riscItems
    in
        case curRiscItem of
            Nothing ->
                opt

            Just curRiscItem_ ->
                { opt
                    | stockPriceAtRisc = M.toDecimal curRiscItem_.risc 100
                    , optionPriceAtRisc = opt.sell - curRisc
                    , risc = curRisc
                }


calcRisc : String -> Maybe Options -> Cmd Msg
calcRisc riscStr options =
    let
        risc =
            Result.withDefault 0 (String.toFloat riscStr)

        url =
            mainUrl ++ "/calc-risc-stockprices"

        opx =
            Maybe.withDefault [] options

        checked =
            List.filter (\x -> x.selected == True) opx

        jbody =
            M.asHttpBody
                (List.map (\x -> ( x.ticker, JE.float risc )) checked)

        myDecoder =
            JP.decode RiscItem
                |> JP.required "ticker" Json.string
                |> JP.required "risc" Json.float
    in
        Http.send RiscCalculated <|
            Http.post url jbody (Json.list myDecoder)


buildOption :
    String
    -> Float
    -> Float
    -> Float
    -> Float
    -> Float
    -> Float
    -> Float
    -> Option
buildOption t x d b s ib is be =
    Option
        t
        x
        d
        b
        s
        ib
        is
        be
        (M.toDecimal (100 * ((s / b) - 1.0)) 10.0)
        0
        0
        0
        False


optionDecoder : Json.Decoder Option
optionDecoder =
    JP.decode buildOption
        |> JP.required "ticker" Json.string
        |> JP.required "x" Json.float
        |> JP.required "days" Json.float
        |> JP.required "buy" Json.float
        |> JP.required "sell" Json.float
        |> JP.required "iv-buy" Json.float
        |> JP.required "iv-sell" Json.float
        |> JP.required "br-even" Json.float


stockDecoder : Json.Decoder Stock
stockDecoder =
    JP.decode Stock
        |> JP.required "dx" Json.string
        |> JP.required "tm" Json.string
        |> JP.required "o" Json.float
        |> JP.required "h" Json.float
        |> JP.required "l" Json.float
        |> JP.required "c" Json.float


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



-- #endregion
