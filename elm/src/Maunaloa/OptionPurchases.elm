module Maunaloa.OptionPurchases exposing (..)

import Http
import Html as H
import Html.Attributes as A
import Common.ComboBox as CMB
import Common.Miscellaneous as MISC


mainUrl =
    "/maunaloa"


main : Program Never Model Msg
main =
    H.program
        { init = init
        , view = view
        , update = update
        , subscriptions = \s -> Sub.none
        }



--#region TYPES


type Msg
    = TickersFetched (Result Http.Error CMB.SelectItems)
    | FetchOptions String



--#endregion
--#region INIT


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )


initModel : Model
initModel =
    { tickers = Nothing
    , selectedTicker = "-1"
    }



--#endregion
--#region MODEL


type alias Model =
    { tickers : Maybe CMB.SelectItems
    , selectedTicker : String
    }



--#endregion
--#region VIEW


view : Model -> H.Html Msg
view model =
    H.div [ A.class "container" ]
        [ H.div [ A.class "row" ]
            [ H.div [ A.class "col-sm-3" ]
                [ CMB.makeSelect "Tickers: " FetchOptions model.tickers model.selectedTicker ]
            ]
        ]



--#endregion
--#region UPDATE


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
            ( { model | selectedTicker = s }, fetchOptions s )



--#endregion
--#region COMMANDS


fetchOptions : String -> Cmd Msg
fetchOptions ticker =
    Cmd.none


fetchTickers : Cmd Msg
fetchTickers =
    let
        url =
            mainUrl ++ "/tickers"
    in
        Http.send TickersFetched <|
            Http.get url CMB.comboBoxItemListDecoder



--#endregion
