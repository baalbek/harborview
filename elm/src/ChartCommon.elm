module ChartCommon exposing (..)

import Svg.Attributes as SA
import String
import Date exposing (Date, year, month, day)
import Time exposing (Time)
import Common.DateUtil as D


type alias Point =
    { x : Float
    , y : Float
    }


type alias Candlestick =
    { o : Float
    , h : Float
    , l : Float
    , c : Float
    }


type alias ChartValues =
    Maybe (List Float)


myStyle =
    SA.style "font: 12px/normal Helvetica, Arial;"


myStroke =
    SA.stroke "#cccccc"



{-
   type Graph
       = Line (List Float)
       | Bar (List Float)
-}


type alias Chart =
    { lines : Maybe (List (List Float))
    , bars : Maybe (List (List Float))
    , candlesticks : Maybe (List Candlestick)
    , height : Float
    , valueRange : ( Float, Float )
    , numVlines : Int
    }


type alias ChartInfo =
    { minDx : Date
    , xAxis : List Float
    , chart : Chart
    , chart2 : Maybe Chart
    }



{-
   dateToDateJs : Date -> DateJs
   dateToDateJs d =
       DateJs (year d) (D.monthToInt <| month d) (day d)
-}


type alias ChartInfoJs =
    { startdate : Time
    , xaxis : List Float
    , chart : Chart
    , chart2 : Maybe Chart
    , strokes : List String
    , numIncMonths : Int
    }



-- , chartLines : ChartLines
-- , candlesticks : Maybe (List Candlestick)
-- , chartLines2 : Maybe ChartLines
-- , strokes : List String
