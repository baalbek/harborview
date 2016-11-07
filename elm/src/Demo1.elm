module Demo1 exposing (..)

import Json.Decode as JD
import Http exposing (url,get)

lox = url "http://localhost:8082/vinapu/locations" [ ("oid", "1") ]

lax = get (JD.list JD.string) lox
