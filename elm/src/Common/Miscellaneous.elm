module Common.Miscellaneous exposing (..)

import Json.Decode as JD
import Json.Encode as JE
import VirtualDom as VD
import Http
import Html as H
import Html.Attributes as A
import Html.Events as E
import Date exposing (Date, fromString, toTime)
import Tuple exposing (first, second)
import Time exposing (Time)


asHttpBody : List ( String, JE.Value ) -> Http.Body
asHttpBody lx =
    let
        x =
            JE.object lx
    in
        Http.stringBody "application/json" (JE.encode 0 x)


findInList : (a -> Bool) -> List a -> Maybe a
findInList predicate list =
    case list of
        [] ->
            Nothing

        first :: rest ->
            if predicate first then
                Just first
            else
                findInList predicate rest


httpErr2str : Http.Error -> String
httpErr2str err =
    case err of
        Http.Timeout ->
            "Timeout"

        Http.NetworkError ->
            "NetworkError"

        Http.BadUrl s ->
            "BadUrl: " ++ s

        Http.BadStatus r ->
            "BadStatus: "

        Http.BadPayload s r ->
            "BadPayload: " ++ s


toDecimal : Float -> Float -> Float
toDecimal value roundFactor =
    let
        valx =
            toFloat <| round <| value * roundFactor
    in
        valx / roundFactor


maybeMap : (a -> a) -> Maybe (List a) -> Maybe (List a)
maybeMap fn lx =
    case lx of
        Nothing ->
            Nothing

        Just lx_ ->
            Just (List.map fn lx_)


minMaxListMaybe : List (Maybe Float) -> Maybe Float
minMaxListMaybe l =
    Just 3


mfunc : (number -> number -> number) -> Maybe number -> Maybe number -> Maybe number
mfunc fn a b =
    case a of
        Nothing ->
            b

        Just ax ->
            case b of
                Nothing ->
                    a

                Just bx ->
                    Just (fn ax bx)



--mplus : Maybe number -> Maybe number -> Maybe number
--mplus a b = mfunc (+) a b


mmin : Maybe number -> Maybe number -> Maybe number
mmin =
    mfunc (min)


mmax : Maybe number -> Maybe number -> Maybe number
mmax =
    mfunc (max)


minMaxTuples : List ( Maybe Float, Maybe Float ) -> Float -> ( Float, Float )
minMaxTuples tuples scale =
    let
        min_ =
            List.map first tuples |> List.foldr mmin Nothing |> Maybe.withDefault 0

        max_ =
            List.map second tuples |> List.foldr mmax Nothing |> Maybe.withDefault 0
    in
        ( min_ / scale, max_ * scale )


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


stringToTimeDecoder : JD.Decoder Time
stringToTimeDecoder =
    let
        resultDecoder x =
            case x of
                Ok a ->
                    JD.succeed (toTime a)

                Err e ->
                    JD.fail e
    in
        JD.map fromString JD.string |> JD.andThen resultDecoder


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


checkbox : String -> Bool -> msg -> H.Html msg
checkbox name selected msg =
    H.div [ A.class "col-sm-4 checkbox" ]
        [ H.label []
            [ H.input [ A.checked selected, A.type_ "checkbox", E.onClick msg ] []
            , H.text name
            ]
        ]
