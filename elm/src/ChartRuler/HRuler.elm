module ChartRuler.HRuler exposing (..)

import Svg as S
import Svg.Attributes as SA
import Time exposing (Time)
import Common.DateUtil as DU
import ChartCommon as C exposing (Point, ChartValues, ChartInfo)
import Date exposing (Date, fromTime)
import Common.Miscellaneous exposing (lastElem)


dci : ChartInfo
dci =
    { minDx = DU.toDate "2016-7-1"
    , maxDx = DU.toDate "2016-8-1"
    , xAxis = List.reverse <| List.map toFloat <| List.range 0 400
    , spots = Just <| List.reverse <| List.map toFloat <| List.range 100 500
    , itrend20 = Nothing
    }


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


hruler : Date -> Date -> List Float -> Float -> String -- (Float -> Float)
hruler newStartDate newEndDate newRange chartWidth =
    let
        days =
            DU.diffDays newStartDate newEndDate

        ppx =
            chartWidth / days

        lastIndex = List.head newRange |> Maybe.withDefault 0 
    in
    "ppx: " ++ (toString ppx) ++ ", days: " ++ (toString days) ++ ", head: " ++ (toString lastIndex)
    -- \x -> chartWidth - ((lastIndex - x) * ppx)
