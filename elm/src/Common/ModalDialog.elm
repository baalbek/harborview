module Common.ModalDialog exposing (..)

import Html as H
import Html.Events as E

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

{-
modalDialog : String -> ModalDialog -> H.Html a
modalDialog title md = 
    H.div [ A.class "modalDialog", A.style [ ( "opacity", md.opacity ), ( "pointer-events", md.pointerEvents ) ] ]
        [ H.div []
            [ H.h4 [] [ H.text title ]
            , H.button [ A.class "btn btn-default", E.onClick LocOk ] [ H.text "OK" ]
            , H.button [ A.class "btn btn-default", E.onClick LocCancel ] [ H.text "Cancel" ]
-}
