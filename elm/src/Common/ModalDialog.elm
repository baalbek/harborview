module Common.ModalDialog
    exposing
        ( ModalDialog
        , dlgOpen
        , dlgClose
        , modalDialog
        )

import VirtualDom as VD
import Html as H
import Html.Attributes as A
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


modalDialog :
    String
    -> ModalDialog
    -> a
    -> a
    -> List (H.Html a)
    -> H.Html a
modalDialog title md ok cancel content =
    let
        titleDiv =
            H.h4 [] [ H.text title ]

        okButton =
            H.button [ A.class "btn btn-default", E.onClick ok ] [ H.text "OK" ]

        cancelButton =
            H.button [ A.class "btn btn-default", E.onClick cancel ] [ H.text "Cancel" ]

        buttons =
            [ okButton
            , cancelButton
            ]
    in
        H.div [ A.class "modalDialog", A.style [ ( "opacity", md.opacity ), ( "pointer-events", md.pointerEvents ) ] ]
            [ H.div []
                (titleDiv
                    :: content
                    ++ buttons
                )
            ]


