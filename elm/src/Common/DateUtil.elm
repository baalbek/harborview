module Common.DateUtil
    exposing (..)

import Date exposing (Date,fromString,toTime,fromTime)
import Time exposing (Time)

day_ : Time
day_ = 86400000 

toSimpleDate : String -> Date
toSimpleDate s = 
    Date.fromString s |> Result.withDefault (Date.fromTime 0)

incDays : Date -> Int -> Date
incDays dx days =
    let x = toTime dx
        tx = x + ((toFloat days) * day_)
    in
        fromTime tx





