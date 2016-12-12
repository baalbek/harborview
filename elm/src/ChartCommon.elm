module ChartCommon exposing (..)

type alias Point =
    { x : Float
    , y : Float }

--type alias ChartPoints =  
--    List (List Float)

type alias CandleStick = 
    { opn : Float
    , hi : Float
    , lo : Float
    , cls : Float }

type ChartValues 
    = CandleSticks (List CandleStick)
    | ChartPoints (List (List Float))
