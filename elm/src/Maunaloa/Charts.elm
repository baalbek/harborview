module Maunaloa.Charts exposing (..)

import Html.App as App
import Html as H
import Common.ModalDialog exposing (ModalDialog, dlgOpen, dlgClose)
import Common.ComboBox
    exposing
        ( ComboBoxItem
        , SelectItems
        , comboBoxItemDecoder
        , comboBoxItemListDecoder
        )


main : Program Never
main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-----------------------------------------------
-------------------- IMIT ---------------------
-----------------------------------------------


init : ( Model, Cmd Msg )
init =
    ( initModel, Cmd.none )



-----------------------------------------------
------------------- MODEL ---------------------
-----------------------------------------------


type alias Model =
    { tickers : Maybe (List String)
    }


initModel : Model
initModel =
    { tickers = Nothing
    }



-----------------------------------------------
-------------------- MSG ----------------------
-----------------------------------------------


type Msg
    = Noop



-----------------------------------------------
-------------------- VIEW ---------------------
-----------------------------------------------


view : Model -> H.Html Msg
view model =
    H.div [] []



-----------------------------------------------
------------------- UPDATE --------------------
-----------------------------------------------


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )



-----------------------------------------------
---------------- SUBSCRIPTIONS ----------------
-----------------------------------------------


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
