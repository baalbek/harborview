module Maunaloa.Options exposing (..)

import Http
import Html as H
import Html.Attributes as A
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


type alias Model =
    { tickers : Maybe CMB.SelectItems
    , selectedTicker : String
    }


initModel : Model
initModel =
    { tickers = Nothing
    , selectedTicker = "-1"
    }



------------------- TYPES ---------------------


type Msg
    = TickersFetched (Result Http.Error CMB.SelectItems)
    | FetchOptions String



-------------------- VIEW ---------------------


view : Model -> H.Html Msg
view model =
    H.div [ A.class "container" ]
        [ H.div [ A.class "row" ]
            [ CMB.makeSelect "Tickers: " FetchOptions model.tickers model.selectedTicker
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
            Debug.log ("TickersFetched Error: " ++ (MISC.httpErr2str s)) ( model, Cmd.none )

        FetchOptions s ->
            ( model, Cmd.none )



------------------ COMMANDS ---------------------


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
