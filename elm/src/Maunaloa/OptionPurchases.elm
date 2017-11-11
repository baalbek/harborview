module Maunaloa.OptionPurchases exposing (..)

import Http
import Html as H
import Html.Attributes as A
import Json.Decode as Json
import Json.Decode.Pipeline as JP
import Common.ComboBox as CMB
import Common.Miscellaneous as MISC
import Common.Buttons as BTN


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
    }


init : ( Model, Cmd Msg )
init =
    ( initModel, fetchTickers )



-- endregion
-- region TYPES


button_ =
    BTN.button "col-sm-2"


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
    }


type alias OptionPurchases =
    List PurchaseWithSales


type Msg
    = TickersFetched (Result Http.Error CMB.SelectItems)
    | ToggleRealTimePurchase
    | FetchPurchases String
    | PurchasesFetched (Result Http.Error OptionPurchases)


type alias Model =
    { tickers : Maybe CMB.SelectItems
    , selectedTicker : String
    , purchases : Maybe OptionPurchases
    , isRealTimePurchase : Bool
    }



-- endregion TYPES
-- region UPDATE


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
            Debug.log ("PurchasesFetched Error: " ++ (MISC.httpErr2str s)) ( model, Cmd.none )



-- endregion
-- region VIEW


tableHeader : H.Html Msg
tableHeader =
    H.thead []
        [ H.tr
            []
            [ H.th [] [ H.text "Oid" ]
            , H.th [] [ H.text "Option Type" ]
            , H.th [] [ H.text "Ticker" ]
            , H.th [] [ H.text "Purchase Date" ]
            , H.th [] [ H.text "Purchase Price" ]
            , H.th [] [ H.text "Bid" ]
            , H.th [] [ H.text "Purchase vol." ]
            , H.th [] [ H.text "Sales vol." ]
            , H.th [] [ H.text "Spot" ]
            , H.th [] [ H.text "Iv" ]
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
                            H.tr []
                                [ H.td [] [ H.text (toString x.oid) ]
                                , H.td [] [ H.text x.optionType ]
                                , H.td [] [ H.text x.ticker ]
                                , H.td [] [ H.text x.purchaseDate ]
                                , H.td [] [ H.text (toString x.price) ]
                                , H.td [] [ H.text (toString x.bid) ]
                                , H.td [] [ H.text (toString x.purchaseVolume) ]
                                , H.td [] [ H.text (toString x.volumeSold) ]
                                , H.td [] [ H.text (toString x.spot) ]
                                , H.td [] [ H.text (toString x.iv) ]
                                ]

                        rows =
                            List.map toRow s
                    in
                        H.table [ A.class "table table-hoover" ]
                            [ tableHeader
                            , H.tbody []
                                rows
                            ]
    in
        H.div [ A.class "container" ]
            [ H.div [ A.class "row" ]
                [ -- button_ "Fetch Purchases" (FetchPurchases model.selectedTicker)
                  MISC.checkbox "Real-time purchase" True ToggleRealTimePurchase
                , H.div [ A.class "col-sm-3" ]
                    [ CMB.makeSelect "Tickers: " FetchPurchases model.tickers model.selectedTicker ]
                ]
            , H.div [ A.class "row" ]
                [ purchaseTable
                ]
            ]



-- endregion
-- region COMMANDS


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
    let
        purchaseType =
            case isRealTime of
                True ->
                    "3"

                False ->
                    "11"

        url =
            mainUrl ++ "/fetchpurchases2?oid=" ++ ticker ++ "&ptype=" ++ purchaseType

        myDecoder =
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
    in
        Http.send PurchasesFetched <|
            Http.get url (Json.list myDecoder)



-- endregion
