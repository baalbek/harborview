module Common.Miscellaneous exposing (..)

import Json.Decode as Json 
import VirtualDom as VD
import Html as H
import Html.Attributes as A
import Html.Events as E


makeLabel : String -> VD.Node a
makeLabel caption =
    H.label [] [ H.text caption ]

makeInput : (String -> a) -> VD.Node a 
makeInput msg = 
    H.input [ A.class "form-control", onChange msg ] []

onChange : (String -> a) -> VD.Property a
onChange tagger =
    E.on "change" (Json.map tagger E.targetValue)
