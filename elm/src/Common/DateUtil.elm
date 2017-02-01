module Common.DateUtil exposing (..)

import Date exposing (Date, fromString, toTime, fromTime)
import Time exposing (Time)


day_ : Time
day_ =
    86400000


week_ : Time
week_ =
    604800000


toDate : String -> Date
toDate s =
    Date.fromString s |> Result.withDefault (Date.fromTime 0)


addDays : Date -> Time -> Date
addDays dx days =
    let
        x =
            toTime dx

        tx =
            x + (days * day_)
    in
        fromTime tx


addWeeks : Date -> Time -> Date
addWeeks dx weeks =
    let
        x =
            toTime dx

        tx =
            x + (weeks * week_)
    in
        fromTime tx
