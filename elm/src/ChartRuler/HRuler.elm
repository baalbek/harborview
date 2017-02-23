module ChartRuler.HRuler exposing (..)

import Svg as S
import Svg.Attributes as SA
import Time exposing (Time)
import Common.DateUtil as DU
import ChartCommon as C exposing (ChartInfo)
import Date exposing (Date, fromTime)
import Common.Miscellaneous exposing (lastElem)


{-
   dci : ChartInfo
   dci =
       { minDx = DU.toDate "2016-7-1"
       , maxDx = DU.toDate "2016-8-1"
       , xAxis = List.reverse <| List.map toFloat <| List.range 0 400
       , lines = [List.reverse <| List.map toFloat <| List.range 100 500]
       , candlesticks = Nothing
       }
-}


dxOf : Date -> Float -> Date
dxOf dx offset =
    DU.addDays dx offset


dateRangeOf : Date -> List Float -> ( Date, Date )
dateRangeOf dx lx =
    let
        offsetHi =
            List.head lx |> Maybe.withDefault 0

        offsetLow =
            lastElem lx |> Maybe.withDefault 0
    in
        ( dxOf dx offsetLow, dxOf dx offsetHi )


lines : Float -> Float -> ChartInfo -> List (S.Svg a)
lines w h ci =
    let
        valueSpan =
            DU.diffDays ci.minDx ci.maxDx

        ppx =
            w / valueSpan

        step =
            w / 10.0

        range =
            List.range 1 9

        h2s =
            toString h

        txtYs =
            toString (h - 5)

        valFn x =
            let
                days =
                    x / ppx

                xDate =
                    DU.addDays ci.minDx days
            in
                (toString <| Date.month xDate) ++ "." ++ (toString <| Date.year xDate)

        lineFn x =
            let
                curX =
                    step * (toFloat x)

                curXl =
                    toString curX

                curXs =
                    toString (curX + 5)

                valX =
                    valFn curX
            in
                [ S.line [ SA.x1 curXl, SA.y1 "0", SA.x2 curXl, SA.y2 h2s, C.myStroke ] []
                , S.text_ [ SA.x curXs, SA.y txtYs, SA.fill "red", C.myStyle ] [ S.text valX ]
                ]
    in
        List.concat <| List.map lineFn range


hruler : Date -> Date -> List Float -> Float -> Float -> Float
hruler newStartDate newEndDate newRange chartWidth rangeIndex =
    let
        days =
            DU.diffDays newStartDate newEndDate

        ppx =
            chartWidth / days

        lastIndex =
            List.head newRange |> Maybe.withDefault 0
    in
        chartWidth - ((lastIndex - rangeIndex) * ppx)



-- "ppx: " ++ (toString ppx) ++ ", days: " ++ (toString days) ++ ", head: " ++ (toString lastIndex)
