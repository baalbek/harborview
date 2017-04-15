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
    ( { tickerModel = { tickers = Nothing, selectedTicker = "-1" } }, Cmd.none )


fx : String -> MS.Msg
fx s =
    MS.MsgForTickers (MS.FetchOptions s)


view : M.Model -> H.Html MS.Msg
view model =
    H.div [ A.class "container" ]
        [ H.div [ A.class "row" ]
            [ --CMB.makeSelect "Tickers: " MS.FetchOptions model.tickerModel.tickers model.tickerModel.selectedTicker
              H.select
                [ E.onInput (\x -> MS.MsgForTickers (MS.FetchOptions x))
                , A.class "form-control"
                ]
                []
            ]
        ]


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
            Debug.log "TickersFetched"
                ( model, Cmd.none )

        MS.TickersFetched (Err s) ->
            ( model, Cmd.none )

        MS.FetchOptions s ->
            Debug.log "FetchOptions"
                ( model, Cmd.none )


subscriptions : M.Model -> Sub MS.Msg
subscriptions model =
    Sub.none
