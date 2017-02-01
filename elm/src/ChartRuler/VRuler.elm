module ChartRuler.VRuler exposing (..)

import Svg as S
import Svg.Attributes as SA
import Time exposing (Time)
import Common.DateUtil as DU
import ChartCommon as C exposing (Point, ChartValues, ChartInfo)
import Date exposing (Date, fromTime)
import Common.Miscellaneous exposing (lastElem)


{-|

    ppy : pixels pr y value

-}



{-
   type alias VRuler =
       { ul : Point
       , lr : Point
       , ppy : Float
       , minVal : Float
       , maxVal :
           Float
           -- , values : Maybe ChartValues
       }


   r : VRuler
   r =
       let
           p0 =
               Point 0 0

           p1 =
               Point 1200 950
       in
           vruler p0 p1 Nothing


   calcValue : VRuler -> Float -> Float
   calcValue ruler pix =
       20.2


   calcPix : VRuler -> Float -> Float
   calcPix ruler val =
       20.2
-}


maybeLen : Maybe (List a) -> Int
maybeLen v =
    case v of
        Nothing ->
            0

        Just v_ ->
            List.length v_


dci : ChartInfo
dci =
    { minDx = DU.toDate "2016-7-1"
    , maxDx = DU.toDate "2016-8-1"
    , xAxis = List.reverse <| List.map toFloat <| List.range 0 400
    , spots = Just <| List.reverse <| List.map toFloat <| List.range 100 500
    , itrend20 = Nothing
    }


vruler : Int -> (Float -> Float)
vruler h =
    let
        vruler_ : Float -> Float
        vruler_ x =
            2 * x
    in
        vruler_


minMax_ : Maybe (List Float) -> ( Float, Float )
minMax_ v =
    case v of
        Nothing ->
            ( 0, 0 )

        Just v_ ->
            let
                minVal =
                    List.minimum v_ |> Maybe.withDefault 0

                maxVal =
                    List.maximum v_ |> Maybe.withDefault 0
            in
                ( minVal, maxVal )


minMax : ChartInfo -> ( Float, Float )
minMax ci =
    let
        ( s1, s2 ) =
            minMax_ ci.spots

        ( i1, i2 ) =
            minMax_ ci.itrend20
    in
        ( min s1 i1, max s2 i2 )



-- List.drop 90 dci.xAxis |> List.take 90 |> dateRangeOf dci


lines : Int -> Int -> ChartInfo -> List (S.Svg a)
lines w h ci =
    let
        --valueSpan =
        --    ci.maxVal - ci.minVal
        ( minVal, maxVal ) =
            minMax ci

        valueSpan =
            maxVal - minVal

        ppy =
            toFloat h / valueSpan

        step =
            ppy * (valueSpan / 10.0)

        x2s =
            toString w

        range =
            List.range 1 10

        lineFn x =
            let
                curY =
                    toString <| step * (toFloat x)
            in
                S.line [ SA.x1 "0", SA.y1 curY, SA.x2 x2s, SA.y2 curY, SA.stroke "#023963" ] []
    in
        List.map lineFn range



{-
   vruler : Point -> Point -> Maybe ChartValues -> VRuler
   vruler ul lr cv =
       let
           ( minVal, maxVal ) =
               minMax cv

           valueSpan =
               maxVal - minVal

           h =
               lr.y - ul.y

           ppy =
               h / valueSpan
       in
           VRuler ul lr ppy minVal maxVal



   minMax : Maybe ChartValues -> ( Float, Float )
   minMax cv =
       case cv of
           Nothing ->
               ( 0.0, 100.0 )

           Just cv_ ->
               ( 0.0, 100.0 )
-}
