module ChartCommon exposing (..)

import String

    {-
stringToDate : Decoder Date
stringToDate =
    string 
        |> andThen (\val ->
             case String.toFloat val of
                Err err -> fail err
                Ok ms -> succeed <| Date.fromTime ms)
                -}


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

