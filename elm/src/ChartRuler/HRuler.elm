module ChartRuler.HRuler exposing (..)

import Svg as S
import Svg.Attributes as SA
import Time exposing (Time)
import Common.DateUtil as DU
import ChartCommon as C exposing (Point, ChartValues, ChartInfo)
import Date exposing (Date, fromTime)
import Common.Miscellaneous exposing (lastElem)


dxOf : Float -> ChartInfo -> Date
dxOf offset ci =
    DU.addDays ci.minDx offset


dateRangeOf : ChartInfo -> List Float -> ( Date, Date )
dateRangeOf ci lx =
    let
        offsetHi =
            List.head lx |> Maybe.withDefault 0

        offsetLow =
            lastElem lx |> Maybe.withDefault 0
    in
        ( dxOf offsetHi ci, dxOf offsetLow ci )
