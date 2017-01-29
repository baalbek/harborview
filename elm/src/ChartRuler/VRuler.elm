module ChartRuler.VRuler exposing (..)

import Svg as S
import Svg.Attributes as SA
import ChartCommon as C exposing (Point, ChartValues, ChartInfo)


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


vruler : Int -> (Float -> Float)
vruler h =
    let
        vruler_ : Float -> Float
        vruler_ x =
            2 * x
    in
        vruler_


lines : Int -> Int -> ChartInfo -> List (S.Svg a)
lines w h ci =
    let
        valueSpan =
            ci.maxVal - ci.minVal

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
