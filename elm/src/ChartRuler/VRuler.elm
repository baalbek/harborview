module ChartRuler.VRuler exposing (..)

import Svg as S
import Svg.Attributes as SA
import Time exposing (Time)
import Common.DateUtil as DU
import ChartCommon as C exposing (ChartValues, ChartInfo)
import Date exposing (Date, fromTime)
import Common.Miscellaneous exposing (lastElem)
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



-- List.drop 90 dci.xAxis |> List.take 90 |> dateRangeOf dci


lines : Float -> Float -> ChartInfo -> List (S.Svg a)
lines w h ci =
    let
        valueSpan =
            ci.maxVal - ci.minVal

        ppy =
            h / valueSpan

        step =
            ppy * (valueSpan / 10.0)

        x2s =
            toString w

        range =
            List.range 1 10

        lineFn x =
            let
                curY =
                    toString <| step * (toFloat x)
            in
                S.line [ SA.x1 "0", SA.y1 curY, SA.x2 x2s, SA.y2 curY, SA.stroke "#023963" ] []
    in
        List.map lineFn range


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
