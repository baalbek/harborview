module Maunaloa.Options exposing (..)

import Http
import Html as H
import Html.Attributes as A
import Json.Decode.Pipeline as JP
import Json.Decode as Json
import Common.Miscellaneous as MISC
import Common.ComboBox as CMB


mainUrl =
    "/maunaloa"


main : Program Never Model Msg
main =
    H.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-------------------- PORTS ---------------------
-------------------- INIT ---------------------


init : ( Model, Cmd Msg )
init =
    ( initModel, fetchTickers )



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
    { puts : List Option
    , calls : List Option
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
    , options : Maybe Options
    }


initModel : Model
initModel =
    { tickers = Nothing
    , selectedTicker = "-1"
    , options = Nothing
    }



------------------- TYPES ---------------------


type Msg
    = TickersFetched (Result Http.Error CMB.SelectItems)
    | FetchOptions String
    | OptionsFetched (Result Http.Error Options)



-------------------- VIEW ---------------------


view : Model -> H.Html Msg
view model =
    H.div [ A.class "container" ]
        [ H.div [ A.class "row" ]
            [ CMB.makeSelect "Tickers: " FetchOptions model.tickers model.selectedTicker
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
            ( { model | selectedTicker = s }, fetchOptions s )

        OptionsFetched (Ok s) ->
            ( { model | options = Just s }, Cmd.none )

        OptionsFetched (Err s) ->
            Debug.log ("OptionsFetched Error: " ++ (MISC.httpErr2str s)) ( model, Cmd.none )



------------------ COMMANDS ---------------------


fetchOptions : String -> Cmd Msg
fetchOptions s =
    let
        url =
            mainUrl ++ "/optionsticker?ticker=" ++ s

        optionDecoder =
            JP.decode Option
                |> JP.required "ticker" Json.string
                |> JP.required "days" Json.float
                |> JP.required "buy" Json.float
                |> JP.required "sell" Json.float
                |> JP.required "iv-buy" Json.float
                |> JP.required "iv-sell" Json.float

        myDecoder =
            JP.decode Options
                |> JP.required "puts" (Json.list optionDecoder)
                |> JP.required "calls" (Json.list optionDecoder)
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
