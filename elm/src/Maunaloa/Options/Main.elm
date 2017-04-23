module Maunaloa.Options.Main exposing (..)

import Http
import Html as H
import Html.Events as E
import Html.Attributes as A
import Common.Miscellaneous as MISC
import Common.ComboBox as CMB
import Maunaloa.Options.Model as M
import Maunaloa.Options.Msg as MS


-- exposing (Msg(..))


mainUrl =
    "/maunaloa"


main : Program Never M.Model MS.Msg
main =
    H.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( M.Model, Cmd MS.Msg )
init =
    ( { tickerModel = { tickers = Nothing, selectedTicker = "-1" } }, fetchTickers )


view : M.Model -> H.Html MS.Msg
view model =
    H.div [ A.class "container" ]
        [ H.div [ A.class "row" ]
            [ CMB.makeSelect "Tickers: " (\x -> MS.MsgForTickers (MS.FetchOptions x)) model.tickerModel.tickers model.tickerModel.selectedTicker
            ]
          {-
             H.select
               [ E.onInput (\x -> MS.MsgForTickers (MS.FetchOptions x))
               , A.class "form-control"
               ]
               []
          -}
        ]



------------------- UPDATE --------------------


update : MS.Msg -> M.Model -> ( M.Model, Cmd MS.Msg )
update msg model =
    case msg of
        MS.MsgForTickers m ->
            updateTix m model

        MS.MsgForOther o ->
            model ! []


updateTix : MS.TickersMsg -> M.Model -> ( M.Model, Cmd MS.Msg )
updateTix msg model =
    case msg of
        MS.TickersFetched (Ok s) ->
            let
                tixM =
                    model.tickerModel

                tixMx =
                    { tixM | tickers = Just s }
            in
                Debug.log "TickersFetched"
                    ( { model
                        | tickerModel = tixMx
                      }
                    , Cmd.none
                    )

        MS.TickersFetched (Err s) ->
            Debug.log ("TickersFetched Error: " ++ (MISC.httpErr2str s)) ( model, Cmd.none )

        MS.FetchOptions s ->
            Debug.log ("FetchOptions" ++ s)
                ( model, Cmd.none )



------------------ COMMANDS ---------------------


fetchTickers : Cmd MS.Msg
fetchTickers =
    let
        url =
            mainUrl ++ "/tickers"

        result =
            Http.get url CMB.comboBoxItemListDecoder

        tixm =
            Http.send (\x -> MS.MsgForTickers (MS.TickersFetched x)) <| result
    in
        tixm



--Http.send MS.TickersFetched <| result
---------------- SUBSCRIPTIONS ----------------


subscriptions : M.Model -> Sub MS.Msg
subscriptions model =
    Sub.none
