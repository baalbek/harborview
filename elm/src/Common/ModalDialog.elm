module Common.ModalDialog
    exposing
        ( ModalDialog
        , dlgOpen
        , dlgClose
        , modalDialog
        , AlertCategory(..)
        , alert
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
            H.button [ A.class "btn btn-info", E.onClick ok ] [ H.text "OK" ]

        cancelButton =
            H.button [ A.class "btn btn-danger", E.onClick cancel ] [ H.text "Cancel" ]

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



{-
   <button type="button" class="btn btn-primary">Primary</button>
   <button type="button" class="btn btn-secondary">Secondary</button>
   <button type="button" class="btn btn-success">Success</button>
   <button type="button" class="btn btn-danger">Danger</button>
   <button type="button" class="btn btn-warning">Warning</button>
   <button type="button" class="btn btn-info">Info</button>
   <button type="button" class="btn btn-light">Light</button>
   <button type="button" class="btn btn-dark">Dark</button>

   <button type="button" class="btn btn-link">Link</button>
-}


type AlertCategory
    = Info
    | Warn
    | Error


alert : String -> String -> AlertCategory -> ModalDialog -> a -> H.Html a
alert title msg alertCat md ok =
    let
        titleDiv =
            H.h4 [] [ H.text title ]

        btnClass =
            case alertCat of
                Info ->
                    "btn btn-outline-info"

                Warn ->
                    "btn btn-outline-warning"

                Error ->
                    "btn btn-outline-danger"

        okButton =
            H.button [ A.class btnClass, E.onClick ok ] [ H.text "OK" ]

        content =
            H.div [] [ H.p [] [ H.text msg ] ]
    in
        H.div [ A.class "modalDialog", A.style [ ( "opacity", md.opacity ), ( "pointer-events", md.pointerEvents ) ] ]
            [ H.div []
                [ titleDiv, content, okButton ]
            ]
