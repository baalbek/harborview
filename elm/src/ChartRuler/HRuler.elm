module ChartRuler.HRuler exposing (..)

import Svg as S
import Svg.Attributes as SA
import Time exposing (Time)
import Common.DateUtil as DU
import ChartCommon as C exposing (ChartInfoJs)
import Date exposing (Date, fromTime)
import Common.Miscellaneous exposing (lastElem)


{-
   dci : ChartInfo
   dci =
       { minDx = DU.toDate "2016-7-1"
       , maxDx = DU.toDate "2016-8-1"
       , xAxis = List.reverse <| List.map toFloat <| List.range 0 400
       , lines = [List.reverse <| List.map toFloat <| List.range 100 500]
       , candlesticks = Nothing
       }
-}
{-
   offsets =
       [ 1024, 1023, 1020, 1019, 1018, 1017, 1016, 1013, 1012, 1011, 1010, 1009, 1006, 1005, 1004, 1003, 1002, 999, 998, 997, 996, 995, 992, 991, 990, 989, 988, 985, 984, 983, 982, 981, 978, 977, 976, 975, 974, 971, 970, 969, 968, 967, 964, 963, 962, 961, 960, 957, 956, 955, 954, 953, 950, 949, 948, 947, 946, 943, 942, 941, 940, 939, 936, 935, 934, 933, 932, 929, 928, 927, 926, 925, 922, 921, 920, 919, 918, 915, 914, 913, 912, 911, 908, 907, 906, 905, 901, 900, 899, 898, 897, 894, 893, 892, 891, 887, 886, 885, 884, 883, 880, 878, 877, 876, 873, 872, 871, 870, 869, 866, 865, 864, 863, 862, 859, 858, 857, 856, 855, 852, 850, 849, 848, 845, 844, 843, 842, 836, 835, 834, 831, 830, 829, 828, 827, 824, 823, 822, 821, 820, 817, 816, 815, 814, 813, 810, 809, 808, 807, 806, 803, 802, 801, 800 ]
-}


dxOf : Date -> Float -> Date
dxOf dx offset =
    DU.addDays dx offset


dateRangeOf : Date -> List Float -> ( Date, Date )
dateRangeOf dx lx =
    let
        offsetHi =
            List.head lx |> Maybe.withDefault 0

        offsetLow =
            lastElem lx |> Maybe.withDefault 0
    in
        ( dxOf dx offsetLow, dxOf dx offsetHi )



{-
   lines : Float -> Float -> Date -> Date -> List (S.Svg a)
   lines w h minDx maxDx =
       let
           valueSpan =
               DU.diffDays minDx maxDx

           ppx =
               w / valueSpan

           step =
               w / 10.0

           range =
               List.range 1 9

           h2s =
               toString h

           txtYs =
               toString (h - 5)

           valFn x =
               let
                   days =
                       x / ppx

                   xDate =
                       DU.addDays minDx days
               in
                   (toString <| Date.day xDate)
                       ++ "."
                       ++ (toString <| Date.month xDate)
                       ++ "."
                       ++ (toString <| Date.year xDate)

           lineFn x =
               let
                   curX =
                       step * (toFloat x)

                   curXl =
                       toString curX

                   curXs =
                       toString (curX + 5)

                   valX =
                       valFn curX
               in
                   [ S.line [ SA.x1 curXl, SA.y1 "0", SA.x2 curXl, SA.y2 h2s, C.myStroke ] []
                   , S.text_ [ SA.x curXs, SA.y txtYs, SA.fill "red", C.myStyle ] [ S.text valX ]
                   ]
       in
           List.concat <| List.map lineFn range
-}


hruler : Date -> Date -> List Float -> Float -> Float -> Float
hruler newStartDate newEndDate newRange chartWidth rangeIndex =
    let
        days =
            DU.diffDays newStartDate newEndDate

        ppx =
            chartWidth / days

        lastIndex =
            List.head newRange |> Maybe.withDefault 0
    in
        chartWidth - ((lastIndex - rangeIndex) * ppx)



-- "ppx: " ++ (toString ppx) ++ ", days: " ++ (toString days) ++ ", head: " ++ (toString lastIndex)
