module Common.DateUtil exposing (..)

import Date
    exposing
        ( Date
        , fromString
        , toTime
        , fromTime
        , Month(..)
        )
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


monthToInt : Month -> Int
monthToInt month =
    case month of
        Jan ->
            0

        Feb ->
            1

        Mar ->
            2

        Apr ->
            3

        May ->
            4

        Jun ->
            5

        Jul ->
            6

        Aug ->
            7

        Sep ->
            8

        Oct ->
            9

        Nov ->
            10

        Dec ->
            11



-- 1 + ((t1 - t0) / day_)
