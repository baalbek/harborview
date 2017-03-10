module ChartRuler.VRuler exposing (..)

import Svg as S
import Svg.Attributes as SA
import Time exposing (Time)
import Common.DateUtil as DU
import ChartCommon as C exposing (Candlestick, Chart)
import Date exposing (Date, fromTime)
import Common.Miscellaneous exposing (lastElem, toDecimal)
import Tuple exposing (first, second)


maybeLen : Maybe (List a) -> Int
maybeLen v =
    case v of
        Nothing ->
            0

        Just v_ ->
            List.length v_


minMax : List Float -> ( Maybe Float, Maybe Float )
minMax v =
    let
        minVal =
            List.minimum v -- |> Maybe.withDefault 0

        maxVal =
            List.maximum v -- |> Maybe.withDefault 0
    in
        ( minVal, maxVal )


maybeMinMax : Maybe (List (List Float)) -> List (Maybe Float, Maybe Float)
maybeMinMax l = 
    case l of
        Nothing -> 
            [(Nothing,Nothing)]

        Just l_ -> 
            List.map minMax l_

minMaxCndl : Maybe (List Candlestick) -> ( Maybe Float, Maybe Float )
minMaxCndl cndl =
    case cndl of
        Nothing -> 
            (Nothing,Nothing)
        Just cndl_ ->
            let
                lows =
                    List.map .l cndl_

                his =
                    List.map .h cndl_

                minVal =
                    List.minimum lows -- |> Maybe.withDefault 0

                maxVal =
                    List.maximum his -- |> Maybe.withDefault 0
            in
                ( minVal, maxVal )


lines : Float -> Int -> Chart -> List (S.Svg a)
lines chartWidth numDivisions chart =
    let
        ( minVal, maxVal ) =
            chart.valueRange

        ppy =
            chart.height / (maxVal - minVal)

        step =
            chart.height / (toFloat numDivisions)

        x2s =
            toString chartWidth

        range =
            List.range 1 numDivisions

        valFn y =
            let
                convY =
                    maxVal - (y / ppy)
            in
                toDecimal convY 10

        line0 =
            let
                curYl =
                    "0"
            in
                [ S.line [ SA.x1 "0", SA.y1 curYl, SA.x2 x2s, SA.y2 curYl, C.myStroke ] []
                , S.text_ [ SA.x "5", SA.y "20", SA.fill "red", C.myStyle ] [ S.text (toString maxVal) ]
                ]

        lineFn x =
            let
                curY =
                    step * (toFloat x)

                curYl =
                    toString curY

                curYs =
                    toString (curY - 5)

                valY =
                    toString (valFn curY)
            in
                [ S.line [ SA.x1 "0", SA.y1 curYl, SA.x2 x2s, SA.y2 curYl, C.myStroke ] []
                , S.text_ [ SA.x "5", SA.y curYs, SA.fill "red", C.myStyle ] [ S.text valY ]
                ]
    in
        line0 ++ (List.concat <| List.map lineFn range)



{-
   lines : Float -> Float -> Int -> ChartLines -> List (S.Svg a)
   lines w h numDivisions ci =
       let
           valueSpan =
               ci.maxVal - ci.minVal

           ppy =
               h / valueSpan

           step =
               h / (toFloat numDivisions)

           x2s =
               toString w

           range =
               List.range 1 numDivisions

           valFn y =
               let
                   convY =
                       ci.maxVal - (y / ppy)
               in
                   toDecimal convY 10

           line0 =
               let
                   curYl =
                       "0"
               in
                   [ S.line [ SA.x1 "0", SA.y1 curYl, SA.x2 x2s, SA.y2 curYl, C.myStroke ] []
                   , S.text_ [ SA.x "5", SA.y "20", SA.fill "red", C.myStyle ] [ S.text (toString ci.maxVal) ]
                   ]

           lineFn x =
               let
                   curY =
                       step * (toFloat x)

                   curYl =
                       toString curY

                   curYs =
                       toString (curY - 5)

                   valY =
                       toString (valFn curY)
               in
                   [ S.line [ SA.x1 "0", SA.y1 curYl, SA.x2 x2s, SA.y2 curYl, C.myStroke ] []
                   , S.text_ [ SA.x "5", SA.y curYs, SA.fill "red", C.myStyle ] [ S.text valY ]
                   ]
       in
           line0 ++ (List.concat <| List.map lineFn range)
-}


vruler : ( Float, Float ) -> Float -> Float -> Float
vruler valueRange chartHeight yValue =
    let
        min_ =
            first valueRange

        max_ =
            second valueRange

        valueSpan =
            max_ - min_

        ppy =
            chartHeight / valueSpan
    in
        (max_ - yValue) * ppy
