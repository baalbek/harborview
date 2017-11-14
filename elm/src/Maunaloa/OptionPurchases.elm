module Maunaloa.OptionPurchases exposing (..)

import Http
import Html as H
import Html.Attributes as A
import Html.Events as E
import Json.Decode as Json
import Json.Decode.Pipeline as JP
import Json.Encode as JE
import Common.ComboBox as CMB
import Common.Miscellaneous as M
import Common.Buttons as BTN
import Common.ModalDialog as DLG


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
    , dlgSell = DLG.dlgClose
    , dlgAlert = DLG.dlgClose
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
    | PurchasesFetched (Result Http.Error OptionPurchases)
    | SellClick PurchaseWithSales
    | SellDlgOk
    | SellDlgCancel
    | SaleOk (Result Http.Error String)
    | SalePriceChange String
    | SaleVolumeChange String
    | AlertOk


type alias Model =
    { tickers : Maybe CMB.SelectItems
    , selectedTicker : String
    , purchases : Maybe OptionPurchases
    , isRealTimePurchase : Bool
    , selectedPurchase : Maybe PurchaseWithSales
    , dlgSell : DLG.ModalDialog
    , dlgAlert : DLG.ModalDialog
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AlertOk ->
            ( { model | dlgAlert = DLG.dlgClose }, Cmd.none )

        TickersFetched (Ok s) ->
            ( { model
                | tickers = Just s
              }
            , Cmd.none
            )

        TickersFetched (Err s) ->
            Debug.log ("TickersFetched Error: " ++ (M.httpErr2str s)) ( model, Cmd.none )

        ToggleRealTimePurchase ->
            let
                checked =
                    not model.isRealTimePurchase
            in
                ( { model | isRealTimePurchase = checked }, fetchPurchases model.selectedTicker checked )

        --( { model | isRealTimePurchase = checked }, Cmd.none )
        FetchPurchases s ->
            ( { model | selectedTicker = s }, fetchPurchases s model.isRealTimePurchase )

        PurchasesFetched (Ok s) ->
            ( { model | purchases = Just s }, Cmd.none )

        PurchasesFetched (Err s) ->
            Debug.log ("PurchasesFetched Error: " ++ (M.httpErr2str s)) ( model, Cmd.none )

        SellClick p ->
            ( { model
                | dlgSell = DLG.dlgOpen
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
                            | dlgSell = DLG.dlgClose
                            , purchases = swap model.purchases curPur.oid (curPur.volumeSold + saleVol)
                          }
                          -- , Cmd.none
                        , sellPurchase curPur.oid saleVol salePri
                        )

        SellDlgCancel ->
            ( { model | dlgSell = DLG.dlgClose }, Cmd.none )

        SaleOk (Ok s) ->
            ( { model | dlgAlert = DLG.dlgOpen }, Cmd.none )

        SaleOk (Err s) ->
            Debug.log ("SaleOk Error: " ++ (M.httpErr2str s))
                ( model, Cmd.none )

        SalePriceChange s ->
            ( { model | salePrice = s }, Cmd.none )

        SaleVolumeChange s ->
            ( { model | saleVolume = s }, Cmd.none )



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
            , H.th [] [ H.text "Purchase Price" ]
            , H.th [] [ H.text "Bid" ]
            , H.th [] [ H.text "Purchase vol." ]
            , H.th [] [ H.text "Sales vol." ]
            , H.th [] [ H.text "Spot" ]
            , H.th [] [ H.text "Iv" ]
            , H.th [] [ H.text "Cur. Ask" ]
            , H.th [] [ H.text "Cur. Bid" ]
            , H.th [] [ H.text "Cur. Iv" ]
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
                                diffBid =
                                    M.toDecimal (x.curBid - x.bid) 10.0

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
                                    , H.td [] [ H.text (toString x.price) ]
                                    , H.td [] [ H.text (toString x.bid) ]
                                    , H.td [] [ H.text (toString x.purchaseVolume) ]
                                    , H.td [] [ H.text (toString x.volumeSold) ]
                                    , H.td [] [ H.text (toString x.spot) ]
                                    , H.td [] [ H.text (toString x.iv) ]
                                    , H.td [] [ H.text (toString x.curAsk) ]
                                    , H.td [] [ H.text (toString x.curBid) ]
                                    , H.td [] [ H.text (toString x.curIv) ]
                                    , H.td [] [ H.text (toString diffBid) ]
                                    , H.td [] [ H.text (toString diffIv) ]
                                    ]

                        rows =
                            List.map toRow s.purchases
                    in
                        H.div [ A.class "row" ]
                            [ H.text ("Date: " ++ s.curDx ++ ", Current spot: " ++ (toString s.curSpot))
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
                [ -- button_ "Fetch Purchases" (FetchPurchases model.selectedTicker)
                  M.checkbox "Real-time purchase" True ToggleRealTimePurchase
                , H.div [ A.class "col-sm-3" ]
                    [ CMB.makeSelect "Tickers: " FetchPurchases model.tickers model.selectedTicker ]
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
            , DLG.alert "Alert!" "Sold!" DLG.Info model.dlgAlert AlertOk

            {-
               , H.div [ A.class "row" ]
                   [ purchaseTable
                   ]
            -}
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


fetchPurchases : String -> Bool -> Cmd Msg
fetchPurchases ticker isRealTime =
    if ticker == "-1" then
        Cmd.none
    else
        let
            purchaseType =
                case isRealTime of
                    True ->
                        "3"

                    False ->
                        "11"

            url =
                mainUrl ++ "/fetchpurchases?oid=" ++ ticker ++ "&ptype=" ++ purchaseType

            purchaseDecoder =
                JP.decode PurchaseWithSales
                    |> JP.required "oid" Json.int
                    |> JP.required "ot" Json.string
                    |> JP.required "ticker" Json.string
                    |> JP.required "dx" Json.string
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