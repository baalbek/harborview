module Common.ModalDialog
    exposing
        ( ModalDialog
        , dlgOpen
        , dlgClose
        )

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



{-
   modalDialog : String
                   -> ModalDialog
                   -> (a -> H.Attribute a)
                   -> (a -> H.Attribute a)
                   -> H.Html (a -> H.Attribute a)
   modalDialog title md ok cancel =
       H.div [ A.class "modalDialog", A.style [ ( "opacity", md.opacity ), ( "pointer-events", md.pointerEvents ) ] ]
           [ H.div []
               [ H.h4 [] [ H.text title ]
               , H.button [ A.class "btn btn-default", E.onClick ok ] [ H.text "OK" ]
               , H.button [ A.class "btn btn-default", E.onClick cancel ] [ H.text "Cancel" ]
               ]
           ]

               , H.div [ A.class "modalDialog", A.style [ ( "opacity", model.dlgSys.opacity ), ( "pointer-events", model.dlgSys.pointerEvents ) ] ]
                   [ H.div []
                       [ H.h4 [] [ H.text ("New System for Location id: " ++ model.selectedLocation) ]
                       , H.label [ A.for "dlg3-name" ] [ H.text "System name:" ]
                       , H.input [ A.class "form-control", A.id "dlg3-name", onChange SysNameChange ] []
                       , H.button [ A.class "btn btn-default", E.onClick SysOk ] [ H.text "OK" ]
                       , H.button [ A.class "btn btn-default", E.onClick SysCancel ] [ H.text "Cancel" ]
                       ]
                   ]
-}
