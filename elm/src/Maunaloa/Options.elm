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
import Common.Miscellaneous as MISC
import Common.ComboBox as CMB
import Common.Buttons as BTN
import Common.ModalDialog as DLG


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


type Msg
    = TickersFetched (Result Http.Error CMB.SelectItems)
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
    , selectedPurchase : Maybe Option

    -- , isRealTimePurchase : Bool
    -- , optionPurchases : Maybe OptionPurchases
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

        {-
           purchaseTable =
               case model.optionPurchases of
                   Nothing ->
                       H.text "Purchases"

                   Just s ->
                       let
                           toRow x =
                               let
                                   predicate =
                                       \z -> z.ticker == x.ticker

                                   curOpx =
                                       MISC.findInList predicate opx

                                   ( curBuy, diff ) =
                                       case curOpx of
                                           Nothing ->
                                               ( -1, -1 )

                                           Just curOpx_ ->
                                               ( curOpx_.buy, curOpx_.buy - x.price )
                               in
                                   H.tr []
                                       [ H.td [] [ H.text (toString x.oid) ]
                                       , H.td [] [ H.text x.ticker ]
                                       , H.td [] [ H.text x.purchaseDate ]
                                       , H.td [] [ H.text (toString x.price) ]
                                       , H.td [] [ H.text (toString x.spot) ]
                                       , H.td [] [ H.text (toString curBuy) ]
                                       , H.td [] [ H.text (toString diff) ]
                                       ]

                           rows =
                               List.map toRow s
                       in
                           H.table [ A.class "table table-hoover" ]
                               [ H.thead []
                                   [ H.tr
                                       []
                                       [ H.th [] [ H.text "Oid" ]
                                       , H.th [] [ H.text "Ticker" ]
                                       , H.th [] [ H.text "Purchase Date" ]
                                       , H.th [] [ H.text "Purchase Price " ]
                                       , H.th [] [ H.text "Spot" ]
                                       , H.th [] [ H.text "Current Price" ]
                                       , H.th [] [ H.text "Diff" ]
                                       ]
                                   ]
                               , H.tbody []
                                   rows
                               ]
        -}
    in
        H.div [ A.class "container" ]
            [ {- H.div [ A.class "row" ]
                     [ button_ "Fetch Purchases" FetchPurchases
                     , MISC.checkbox "Real-time purchase" True ToggleRealTimePurchase
                     ]
                 , H.div [ A.class "row" ]
                     [ purchaseTable
                     ]
              -}
              H.div [ A.class "row" ]
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
                []
            ]



-- #endregion


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
    , selectedPurchase = Nothing

    -- , isRealTimePurchase = True
    -- , optionPurchases = Nothing
    }



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
            Debug.log ("TickersFetched Error: " ++ (MISC.httpErr2str s)) ( model, Cmd.none )

        FetchOptions s ->
            ( { model | selectedTicker = s }, fetchOptions model s False )

        OptionsFetched (Ok s) ->
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
            ( model, calcRisc model )

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
            Debug.log ("RiscCalculated Error: " ++ (MISC.httpErr2str s)) ( model, Cmd.none )

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
            ( { model | dlgPurchase = DLG.DialogVisible, selectedPurchase = Just opt }, Cmd.none )

        PurchaseDlgOk ->
            ( { model | dlgPurchase = DLG.DialogHidden }, Cmd.none )

        PurchaseDlgCancel ->
            ( { model | dlgPurchase = DLG.DialogHidden }, Cmd.none )



{-
      FetchPurchases ->
          ( model, fetchOptionPurchases model.selectedTicker model.isRealTimePurchase model.flags.isCalls )

      PurchasesFetched (Ok s) ->
          ( { model | optionPurchases = Just s }, Cmd.none )

      PurchasesFetched (Err s) ->
          Debug.log ("PurchasesFetched Error: " ++ (MISC.httpErr2str s)) ( model, Cmd.none )
   ToggleRealTimePurchase ->
       let
           checked =
               not model.isRealTimePurchase
       in
           ( { model | isRealTimePurchase = checked }, fetchOptionPurchases model.selectedTicker checked model.flags.isCalls )

-}
-- #endregion
-- #region COMMANDS
{-

   fetchOptionPurchases : String -> Bool -> Bool -> Cmd Msg
   fetchOptionPurchases ticker isRealTime isCalls =
       let
           purchaseType =
               case isRealTime of
                   True ->
                       "3"

                   False ->
                       "11"

           optype =
               case isCalls of
                   True ->
                       "c"

                   False ->
                       "p"

           url =
               mainUrl ++ "/fetchpurchases?oid=" ++ ticker ++ "&ptype=" ++ purchaseType ++ "&optype=" ++ optype

           myDecoder =
               JP.decode OptionPurchaseWithSale
                   |> JP.required "oid" Json.int
                   |> JP.required "ticker" Json.string
                   |> JP.required "dx" Json.string
                   |> JP.required "price" Json.float
                   |> JP.required "spot" Json.float
       in
           Http.send PurchasesFetched <|
               Http.get url (Json.list myDecoder)


-}


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
            MISC.findInList predicate riscItems
    in
        case curRiscItem of
            Nothing ->
                opt

            Just curRiscItem_ ->
                { opt
                    | stockPriceAtRisc = MISC.toDecimal curRiscItem_.risc 100
                    , optionPriceAtRisc = opt.sell - curRisc
                    , risc = curRisc
                }


calcRisc : Model -> Cmd Msg
calcRisc model =
    let
        risc =
            Result.withDefault 0 (String.toFloat model.risc)

        url =
            mainUrl ++ "/calc-risc-stockprices"

        opx =
            Maybe.withDefault [] model.options

        checked =
            List.filter (\x -> x.selected == True) opx

        jbody =
            MISC.asHttpBody
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
        (MISC.toDecimal (100 * ((s / b) - 1.0)) 10.0)
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
