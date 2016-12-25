module Common.Miscellaneous exposing (..)

import Json.Decode as Json
import VirtualDom as VD
import Html as H
import Html.Attributes as A
import Html.Events as E
import Date exposing (Date,fromString)

stringToDateDecoder : Json.Decoder Date
stringToDateDecoder = Json.customDecoder Json.string fromString

makeLabel : String -> VD.Node a
makeLabel caption =
    H.label [] [ H.text caption ]


makeInput : (String -> a) -> VD.Node a
makeInput msg =
    H.input [ A.class "form-control", onChange msg ] []

type ColXs = CX66
            | CX48
            | CX39
            | CX210

colXs : ColXs -> (String,String)
colXs x =
    case x of 
        CX66 -> ("col-xs-6 col-form-label","col-xs-6")
        CX48 -> ("col-xs-4 col-form-label","col-xs-8")
        CX39 -> ("col-xs-3 col-form-label","col-xs-9")
        CX210 -> ("col-xs-2 col-form-label","col-xs-10")

{-|

    Makes a bootstrap form-group row with input

    lbl : label text

    aType : type of input

    defVal : default value of input
-}
makeFGRInput : (String -> a) -> String -> String -> String -> ColXs -> Maybe String -> VD.Node a
makeFGRInput msg id lbl aType cx defVal =
    let
        defVal' = Maybe.withDefault "" defVal
        
        cx' = colXs cx
        
    in
        H.div [ A.class "form-group row" ]
            [ H.label [ A.for id, A.class (fst cx') ] [ H.text lbl ]
            , H.div [ A.class (snd cx') ]
                [ H.input [ A.step "0.1", A.class "form-control", A.attribute "type" aType, A.value defVal', A.id id ]
                    []
                ]
            ]


onChange : (String -> a) -> VD.Property a
onChange tagger =
    E.on "change" (Json.map tagger E.targetValue)
