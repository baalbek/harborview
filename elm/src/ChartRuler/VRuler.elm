module ChartRuler.VRuler exposing (..)

import Svg as S
import Svg.Attributes as SA
import Time exposing (Time)
import Common.DateUtil as DU
import ChartCommon as C exposing (Candlestick, ChartValues, ChartInfo)
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


minMax : ChartValues -> ( Float, Float )
minMax v =
    case v of
        Nothing ->
            ( 0, 0 )

        Just v_ ->
            let
                minVal =
                    List.minimum v_ |> Maybe.withDefault 0

                maxVal =
                    List.maximum v_ |> Maybe.withDefault 0
            in
                ( minVal, maxVal )


minMaxCndl : List Candlestick -> ( Float, Float )
minMaxCndl cndl =
    let
        lows =
            List.map .l cndl

        his =
            List.map .h cndl
    in
        ( List.minimum lows, List.maximum his )



-- List.drop 90 dci.xAxis |> List.take 90 |> dateRangeOf dci


lines : Float -> Float -> ChartInfo -> List (S.Svg a)
lines w h cix =
    case cix of
        C.EmptyChartInfo ->
            []

        C.ChartInfo2 ci ->
            []

        C.ChartInfo1 ci ->
            let
                valueSpan =
                    ci.base.maxVal - ci.base.minVal

                ppy =
                    h / valueSpan

                step =
                    ppy * (valueSpan / 10.0)

                x2s =
                    toString w

                range =
                    List.range 1 10

                valFn y =
                    let
                        convY =
                            ci.base.maxVal - (y / ppy)
                    in
                        toDecimal convY 10

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
                        [ S.line [ SA.x1 "0", SA.y1 curYl, SA.x2 x2s, SA.y2 curYl, SA.stroke "#023963" ] []
                        , S.text_ [ SA.x "5", SA.y curYs, SA.fill "red", SA.style "font: 20px/normal Helvetica, Arial;" ] [ S.text valY ]
                        ]
            in
                List.concat <| List.map lineFn range


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
