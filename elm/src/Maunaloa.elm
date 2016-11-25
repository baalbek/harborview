module Maunaloa exposing (..)


main : Program Never
main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-----------------------------------------------
--------------- MODAL DIALOG ------------------
-----------------------------------------------


type alias ModalDialog =
    { opacity : String
    , pointerEvents : String
    }


dlgOpen : ModalDialog
dlgOpen =
    ModalDialog "1" "auto"


dlgClose : ModalDialog
dlgClose =
    ModalDialog "0" "none"



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
