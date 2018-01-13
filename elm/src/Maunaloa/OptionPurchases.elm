module Maunaloa.OptionPurchases exposing (..)

import Common.Buttons as BTN
import Common.ComboBox as CMB
import Common.Miscellaneous as M
import Common.ModalDialog as DLG
import Html as H
import Html.Attributes as A
import Html.Events as E
import Http
import Json.Decode as Json
import Json.Decode.Pipeline as JP
import Json.Encode as JE


-- region Init


mainUrl =
    "/maunaloa"


main : Program Never Model Msg
main =
    H.program
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


initModel : Model
initModel =
    { tickers = Nothing
    , selectedTicker = "-1"
    , purchases = Nothing
    , isRealTimePurchase = True
    , dlgSell = DLG.DialogHidden
    , dlgAlert = DLG.DialogHidden
    , selectedPurchase = Nothing
    , salePrice = "0.0"
    , saleVolume = "10"
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, fetchTickers )



-- endregion
-- region TYPES
{-
   button_ =
       BTN.button "col-sm-2"
-}


type alias PurchaseWithSales =
    { oid : Int
    , optionType : String
    , ticker : String
    , purchaseDate : String
    , exp : String
    , days : Int
    , price : Float
    , bid : Float
    , spot : Float
    , purchaseVolume : Int
    , volumeSold : Int
    , iv : Float
    , curAsk : Float
    , curBid : Float
    , curIv : Float
    }


type alias OptionPurchases =
    { curSpot : Float
    , curDx : String
    , purchases : List PurchaseWithSales
    }


type Msg
    = TickersFetched (Result Http.Error CMB.SelectItems)
    | ToggleRealTimePurchase
    | FetchPurchases String
    | FetchPurchasesAll
    | PurchasesAllFetched (Result Http.Error CMB.SelectItems)
    | PurchasesFetched (Result Http.Error OptionPurchases)
    | SellClick PurchaseWithSales
    | SellDlgOk
    | SellDlgCancel
    | SaleOk (Result Http.Error String)
    | SalePriceChange String
    | SaleVolumeChange String
    | AlertOk
    | ResetCache
    | ResetCacheAll


type alias Model =
    { tickers : Maybe CMB.SelectItems
    , selectedTicker : String
    , purchases : Maybe OptionPurchases
    , isRealTimePurchase : Bool
    , selectedPurchase : Maybe PurchaseWithSales
    , dlgSell : DLG.DialogState
    , dlgAlert : DLG.DialogState
    , salePrice : String
    , saleVolume : String
    }



-- endregion TYPES
-- region UPDATE


swap : Maybe OptionPurchases -> Int -> Int -> Maybe OptionPurchases
swap lx oid saleVol =
    case lx of
        Nothing ->
            Nothing

        Just lxx ->
            let
                swapFn : PurchaseWithSales -> PurchaseWithSales
                swapFn x =
                    if x.oid == oid then
                        { x | volumeSold = x.volumeSold + saleVol }
                    else
                        x

                modifiedPurchases =
                    List.map swapFn lxx.purchases
            in
                Just { lxx | purchases = modifiedPurchases }


errorAlert : Http.Error -> Cmd Msg
errorAlert err =
    Cmd.none


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
            let
                errStr =
                    "TickersFetched Error: " ++ M.httpErr2str s
            in
                ( { model | dlgAlert = DLG.DialogVisibleAlert "TickersFetched ERROR!" errStr DLG.Error }, Cmd.none )

        ToggleRealTimePurchase ->
            let
                checked =
                    not model.isRealTimePurchase

                curCmd =
                    if model.selectedTicker == "-1" then
                        Cmd.none
                    else
                        fetchPurchases model.selectedTicker checked False
            in
                ( { model | isRealTimePurchase = checked }, curCmd )

        --( { model | isRealTimePurchase = checked }, Cmd.none )
        FetchPurchases s ->
            let
                curCmd =
                    if s == "1" then
                        Cmd.none
                    else
                        fetchPurchases s model.isRealTimePurchase False
            in
                ( { model | selectedTicker = s }, curCmd )

        PurchasesFetched (Ok s) ->
            ( { model | purchases = Just s }, Cmd.none )

        PurchasesFetched (Err s) ->
            let
                errStr =
                    "PurchasesFetched Error: " ++ M.httpErr2str s
            in
                ( { model | dlgAlert = DLG.DialogVisibleAlert "PurchasesFetched ERROR!" errStr DLG.Error }, Cmd.none )

        FetchPurchasesAll ->
            ( model, Cmd.none )

        PurchasesAllFetched (Ok s) ->
            ( model, Cmd.none )

        PurchasesAllFetched (Err s) ->
            let
                errStr =
                    "PurchasesAllFetched Error: " ++ M.httpErr2str s
            in
                ( { model | dlgAlert = DLG.DialogVisibleAlert "PurchasesFetched ERROR!" errStr DLG.Error }, Cmd.none )

        SellClick p ->
            ( { model
                | dlgSell = DLG.DialogVisible
                , selectedPurchase = Just p
                , salePrice = toString p.curBid
                , saleVolume = toString (p.purchaseVolume - p.volumeSold)
              }
            , Cmd.none
            )

        SellDlgOk ->
            case model.selectedPurchase of
                Nothing ->
                    ( model, Cmd.none )

                Just curPur ->
                    let
                        saleVol =
                            M.unpackEither model.saleVolume String.toInt -1

                        salePri =
                            M.unpackEither model.salePrice String.toFloat -1
                    in
                        ( { model
                            | dlgSell = DLG.DialogHidden
                            , purchases = swap model.purchases curPur.oid saleVol

                            -- , purchases = swap model.purchases curPur.oid (curPur.volumeSold + saleVol)
                          }
                          -- , Cmd.none
                        , sellPurchase curPur.oid saleVol salePri
                        )

        SellDlgCancel ->
            ( { model | dlgSell = DLG.DialogHidden }, Cmd.none )

        SaleOk (Ok s) ->
            ( { model | dlgAlert = DLG.DialogVisibleAlert "Purchase Sale" s DLG.Info }, Cmd.none )

        SaleOk (Err s) ->
            let
                errStr =
                    "SaleOk Error: " ++ M.httpErr2str s
            in
                ( { model | dlgAlert = DLG.DialogVisibleAlert "Purchase Sale ERROR!" errStr DLG.Error }, Cmd.none )

        SalePriceChange s ->
            ( { model | salePrice = s }, Cmd.none )

        SaleVolumeChange s ->
            ( { model | saleVolume = s }, Cmd.none )

        ResetCache ->
            ( model, fetchPurchases model.selectedTicker model.isRealTimePurchase True )

        ResetCacheAll ->
            ( model, Cmd.none )



-- endregion
-- region VIEW


tableHeader : H.Html Msg
tableHeader =
    H.thead []
        [ H.tr
            []
            [ H.th [] [ H.text "Sell" ]
            , H.th [] [ H.text "Oid" ]
            , H.th [] [ H.text "Option Type" ]
            , H.th [] [ H.text "Ticker" ]
            , H.th [] [ H.text "Purchase Date" ]
            , H.th [] [ H.text "Expiry" ]
            , H.th [] [ H.text "Days" ]
            , H.th [] [ H.text "Purchase Price" ]
            , H.th [] [ H.text "Bid" ]
            , H.th [] [ H.text "Purchase vol." ]
            , H.th [] [ H.text "Sales vol." ]
            , H.th [] [ H.text "Spot" ]
            , H.th [] [ H.text "Iv" ]
            , H.th [] [ H.text "Cur. Ask" ]
            , H.th [] [ H.text "Cur. Bid" ]
            , H.th [] [ H.text "Cur. Iv" ]
            , H.th [] [ H.text "Profit" ]
            , H.th [] [ H.text "Diff Bid" ]
            , H.th [] [ H.text "Diff Iv Pct" ]
            ]
        ]


view : Model -> H.Html Msg
view model =
    let
        purchaseTable =
            case model.purchases of
                Nothing ->
                    H.table [ A.class "table table-hoover" ]
                        [ tableHeader
                        , H.tbody [] []
                        ]

                Just s ->
                    let
                        toRow x =
                            let
                                profit =
                                    M.toDecimal (x.curBid - x.price) 100.0

                                diffBid =
                                    M.toDecimal (x.curBid - x.bid) 100.0

                                diffIv =
                                    M.toDecimal (100.0 * ((x.curIv / x.iv) - 1.0)) 100.0

                                oidStr =
                                    toString x.oid
                            in
                                H.tr []
                                    [ H.button [ A.class "btn btn-success", E.onClick (SellClick x) ] [ H.text ("Sell " ++ oidStr) ]
                                    , H.td [] [ H.text oidStr ]
                                    , H.td [] [ H.text x.optionType ]
                                    , H.td [] [ H.text x.ticker ]
                                    , H.td [] [ H.text x.purchaseDate ]
                                    , H.td [] [ H.text x.exp ]
                                    , H.td [] [ H.text (toString x.days) ]
                                    , H.td [] [ H.text (toString x.price) ]
                                    , H.td [] [ H.text (toString x.bid) ]
                                    , H.td [] [ H.text (toString x.purchaseVolume) ]
                                    , H.td [] [ H.text (toString x.volumeSold) ]
                                    , H.td [] [ H.text (toString x.spot) ]
                                    , H.td [] [ H.text (toString x.iv) ]
                                    , H.td [] [ H.text (toString x.curAsk) ]
                                    , H.td [] [ H.text (toString x.curBid) ]
                                    , H.td [] [ H.text (toString x.curIv) ]
                                    , H.td [] [ H.text (toString profit) ]
                                    , H.td [] [ H.text (toString diffBid) ]
                                    , H.td [] [ H.text (toString diffIv) ]
                                    ]

                        rows =
                            List.map toRow s.purchases
                    in
                        H.div [ A.class "row" ]
                            [ H.text ("Date: " ++ s.curDx ++ ", Current spot: " ++ toString s.curSpot)
                            , H.table [ A.class "table table-hoover" ]
                                [ tableHeader
                                , H.tbody []
                                    rows
                                ]
                            ]

        dlgHeader =
            case model.selectedPurchase of
                Nothing ->
                    "Option Sale:"

                Just sp ->
                    "Option Sale: " ++ sp.ticker
    in
        H.div [ A.class "container" ]
            [ H.div [ A.class "row" ]
                [ M.checkbox "Real-time purchase" "col-sm-2 checkbox" True ToggleRealTimePurchase
                , H.div [ A.class "col-sm-3" ]
                    [ CMB.makeSelect "Tickers: " FetchPurchases model.tickers model.selectedTicker ]
                , BTN.button "col-sm-2" "Reset Cache" ResetCache
                , BTN.button "col-sm-2" "Fetch all purchases" FetchPurchasesAll
                ]
            , purchaseTable
            , DLG.modalDialog dlgHeader
                model.dlgSell
                SellDlgOk
                SellDlgCancel
                [ M.makeLabel "Sale Price:"
                , M.makeInput SalePriceChange model.salePrice
                , M.makeLabel "Sale Volume:"
                , M.makeInput SaleVolumeChange model.saleVolume
                ]
            , DLG.alert model.dlgAlert AlertOk
            ]



-- endregion
-- region COMMANDS


sellPurchase : Int -> Int -> Float -> Cmd Msg
sellPurchase oid volume price =
    let
        url =
            mainUrl ++ "/sellpurchase"

        params =
            [ ( "oid", JE.int oid )
            , ( "vol", JE.int volume )
            , ( "price", JE.float price )
            ]

        jbody =
            M.asHttpBody params
    in
        Http.send SaleOk <|
            Http.post url jbody Json.string


fetchTickers : Cmd Msg
fetchTickers =
    let
        url =
            mainUrl ++ "/tickers"
    in
        Http.send TickersFetched <|
            Http.get url CMB.comboBoxItemListDecoder


fetchPurchases : String -> Bool -> Bool -> Cmd Msg
fetchPurchases ticker isRealTime resetCache =
    let
        purchaseType =
            case isRealTime of
                True ->
                    "3"

                False ->
                    "11"

        resetCacheJson =
            case resetCache of
                True ->
                    "true"

                False ->
                    "false"

        url =
            mainUrl ++ "/fetchpurchases?oid=" ++ ticker ++ "&ptype=" ++ purchaseType ++ "&resetcache=" ++ resetCacheJson

        purchaseDecoder =
            JP.decode PurchaseWithSales
                |> JP.required "oid" Json.int
                |> JP.required "ot" Json.string
                |> JP.required "ticker" Json.string
                |> JP.required "dx" Json.string
                |> JP.required "exp" Json.string
                |> JP.required "days" Json.int
                |> JP.required "price" Json.float
                |> JP.required "bid" Json.float
                |> JP.required "spot" Json.float
                |> JP.required "pvol" Json.int
                |> JP.required "svol" Json.int
                |> JP.required "iv" Json.float
                |> JP.required "cur-ask" Json.float
                |> JP.required "cur-bid" Json.float
                |> JP.required "cur-iv" Json.float

        myDecoder =
            JP.decode OptionPurchases
                |> JP.required "cur-spot" Json.float
                |> JP.required "cur-dx" Json.string
                |> JP.required "purchases" (Json.list purchaseDecoder)
    in
        Http.send PurchasesFetched <|
            Http.get url myDecoder



-- endregion
