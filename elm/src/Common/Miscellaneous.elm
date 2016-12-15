module Common.Widgets exposing (..)

import VirtualDom as VD
import Html as H
import Html.Events as E

import Common.ComboBox

makeLabel : String -> VD.Node a
makeLabel caption =
    H.label [] [ H.text caption ]

makeInput : a -> VD.Node a 
makeInput msg = 
    H.input [ A.class "form-control", onChange msg ] []

onChange : (String -> a) -> VD.Property a
onChange tagger =
    E.on "change" (Json.map tagger E.targetValue)
