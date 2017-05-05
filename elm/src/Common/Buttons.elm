module Common.Buttons exposing (..)

import VirtualDom as VD
import Html as H
import Html.Attributes as A
import Html.Events as E

button :
    String
    -> String
    -> a
    -> VD.Node a
button clazz caption clickEvent =
    H.div [ A.class clazz ]
        [ H.button [ A.class "btn btn-default", E.onClick clickEvent ] [ H.text caption ]
        ]
