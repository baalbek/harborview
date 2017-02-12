module Common.Miscellaneous exposing (..)

import Json.Decode as JD
import VirtualDom as VD
import Html as H
import Html.Attributes as A
import Html.Events as E
import Date exposing (Date, fromString)
import Tuple exposing (first, second)


minMaxTuples : List ( Float, Float ) -> ( Float, Float )
minMaxTuples tuples =
    let
        min_ =
            List.map first tuples |> List.minimum |> Maybe.withDefault 0

        max_ =
            List.map second tuples |> List.maximum |> Maybe.withDefault 0
    in
        ( min_, max_ )


maybeMap : (a -> a) -> Maybe (List a) -> Maybe (List a)
maybeMap fn lx =
    case lx of
        Nothing ->
            Nothing

        Just lx_ ->
            Just (List.map fn lx_)


customDecoder : JD.Decoder a -> (a -> Result String b) -> JD.Decoder b
customDecoder d f =
    let
        resultDecoder x =
            case x of
                Ok a ->
                    JD.succeed a

                Err e ->
                    JD.fail e
    in
        JD.map f d |> JD.andThen resultDecoder


stringToDateDecoder : JD.Decoder Date
stringToDateDecoder =
    customDecoder JD.string fromString


makeLabel : String -> VD.Node a
makeLabel caption =
    H.label [] [ H.text caption ]


makeInput : (String -> a) -> VD.Node a
makeInput msg =
    H.input [ A.class "form-control", onChange msg ] []


type ColXs
    = CX66
    | CX48
    | CX39
    | CX210


colXs : ColXs -> ( String, String )
colXs x =
    case x of
        CX66 ->
            ( "col-xs-6 col-form-label", "col-xs-6" )

        CX48 ->
            ( "col-xs-4 col-form-label", "col-xs-8" )

        CX39 ->
            ( "col-xs-3 col-form-label", "col-xs-9" )

        CX210 ->
            ( "col-xs-2 col-form-label", "col-xs-10" )


{-|

    Makes a bootstrap form-group row with input

    lbl : label text

    aType : type of input

    defVal : default value of input
-}
makeFGRInput : (String -> a) -> String -> String -> String -> ColXs -> String -> VD.Node a
makeFGRInput msg id lbl aType cx inputValue =
    let
        cx_ =
            colXs cx
    in
        H.div [ A.class "form-group row" ]
            [ H.label [ A.for id, A.class (first cx_) ] [ H.text lbl ]
            , H.div [ A.class (second cx_) ]
                [ H.input [ onChange msg, A.step "0.1", A.class "form-control", A.attribute "type" aType, A.value inputValue, A.id id ]
                    []
                ]
            ]


onChange : (String -> a) -> VD.Property a
onChange tagger =
    E.on "change" (JD.map tagger E.targetValue)


lastElem : List a -> Maybe a
lastElem =
    List.foldl (Just >> always) Nothing
