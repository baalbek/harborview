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


type alias Option =
    { ticker : String
    , days : Float
    , buy : Float
    , sell : Float
    , ivBuy : Float
    , ivSell : Float
    }


type alias Options =
    List Option



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
    , options : Maybe Options
    , flags : Flags
    , tableState : Table.State
    }


initModel : Flags -> Model
initModel flags =
    { tickers = Nothing
    , selectedTicker = "-1"
    , options = Nothing
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
            [ Table.stringColumn "Ticker" .ticker
            , Table.floatColumn "Days" .days
            , Table.floatColumn "Buy" .buy
            , Table.floatColumn "Sell" .sell
            , Table.floatColumn "IvBuy" .ivBuy
            , Table.floatColumn "IvSell" .ivSell
            ]
        , customizations =
            defaultCustomizations

        -- { defaultCustomizations | rowAttrs = toRowAttrs }
        }



{-
   toRowAttrs : Option -> List (Attribute Msg)
   toRowAttrs opt =
     [ onClick (ToggleSelected opt.ticker)
     , style [ ("background", if sight.selected then "#CEFAF8" else "white") ]
     ]
-}
------------------- TYPES ---------------------


type Msg
    = TickersFetched (Result Http.Error CMB.SelectItems)
    | FetchOptions String
    | OptionsFetched (Result Http.Error Options)
    | SetTableState Table.State



-------------------- VIEW ---------------------


optionToHtml : Option -> H.Html Msg
optionToHtml opt =
    H.tr []
        [ H.td []
            [ H.text opt.ticker ]
        , H.td []
            [ H.text (toString opt.days) ]
        , H.td []
            [ H.text (toString opt.buy) ]
        , H.td []
            [ H.text (toString opt.sell) ]
        , H.td []
            [ H.text (toString opt.ivBuy) ]
        , H.td []
            [ H.text (toString opt.ivSell) ]
        ]


optionThead : H.Html Msg
optionThead =
    H.thead []
        [ H.tr []
            [ H.th []
                [ H.text "Ticker" ]
            , H.th []
                [ H.text "Days" ]
            , H.th []
                [ H.text "Buy" ]
            , H.th []
                [ H.text "Sell" ]
            , H.th []
                [ H.text "Iv. buy" ]
            , H.th []
                [ H.text "Iv. sell" ]
            ]
        ]


view : Model -> H.Html Msg
view model =
    let
        {-
           derivatives =
               case model.options of
                   Nothing ->
                       [ optionThead ]

                   Just callx ->
                       [ optionThead, H.tbody [] (List.map optionToHtml callx) ]

           tableId =
               case model.flags.isCalls of
                   True ->
                       "table-calls"

                   False ->
                       "table-puts"
        -}
        derivatives =
            case model.options of
                Nothing ->
                    []

                Just opx ->
                    opx
    in
        H.div [ A.class "container" ]
            [ H.div [ A.class "row" ]
                [ CMB.makeSelect "Tickers: " FetchOptions model.tickers model.selectedTicker
                ]
            , H.div [ A.class "row" ]
                [ Table.view config model.tableState derivatives
                ]

            {-
               [ H.table [ A.class "table", A.id tableId ]
                   derivatives
               ]
            -}
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
            ( { model | selectedTicker = s }, fetchOptions model s )

        OptionsFetched (Ok s) ->
            -- Debug.log "CallsFetched"
            ( { model | options = Just s }, Cmd.none )

        OptionsFetched (Err s) ->
            Debug.log ("OptionsFetched Error: " ++ (MISC.httpErr2str s)) ( model, Cmd.none )

        SetTableState newState ->
            ( { model | tableState = newState }
            , Cmd.none
            )



------------------ COMMANDS ---------------------


optionDecoder : Json.Decoder Option
optionDecoder =
    JP.decode Option
        |> JP.required "ticker" Json.string
        |> JP.required "days" Json.float
        |> JP.required "buy" Json.float
        |> JP.required "sell" Json.float
        |> JP.required "iv-buy" Json.float
        |> JP.required "iv-sell" Json.float


fetchOptions : Model -> String -> Cmd Msg
fetchOptions model s =
    let
        url =
            case model.flags.isCalls of
                True ->
                    mainUrl ++ "/calls?ticker=" ++ s

                False ->
                    mainUrl ++ "/puts?ticker=" ++ s

        myDecoder =
            Json.list optionDecoder

        --    JP.decode Options
        --        |> JP.required "calls" (Json.list optionDecoder)
    in
        Http.send OptionsFetched <|
            Http.get url myDecoder



{-
   fetchOptions : String -> Cmd Msg
   fetchOptions s =
       let
           url =
               mainUrl ++ "/optionsticker?ticker=" ++ s


           myDecoder =
               JP.decode PutsCalls
                   |> JP.required "puts" (Json.list optionDecoder)
                   |> JP.required "calls" (Json.list optionDecoder)
       in
           Http.send OptionsFetched <|
               Http.get url myDecoder
-}


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
