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


{-|

  d0 : earlier date

  d1 : later date

  returns number of days from d0 upto, but not including d1

-}
diffDays : Date -> Date -> Time
diffDays d0 d1 =
    let
        t0 =
            toTime d0

        t1 =
            toTime d1
    in
        (t1 - t0) / day_



-- 1 + ((t1 - t0) / day_)
