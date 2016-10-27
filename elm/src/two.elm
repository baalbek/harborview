import Json.Decode as JD
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Maybe

targetSelectedIndex = JD.at ["target", "selectedIndex"] JD.int

type alias Model = { selected : Maybe Int }
model = { selected = Nothing }

type Action = NoOp | Select Int
update action model =
  case action of
    NoOp -> model
    Select s -> { model | selected = Just s }

view address model =
  let
    selectEvent = HE.on "change" targetSelectedIndex
                  (S.message address << Select)
  in
    H.div []
       [ H.select [ HA.size 3, selectEvent ]
            [ H.option [] [ H.text "1" ]
            , H.option [] [ H.text "2" ]
            , H.option [] [ H.text "3" ]
            ]
       , H.p [] [ H.text <| Maybe.withDefault ""
                     <| Maybe.map toString model.selected ]
       ]

actions = S.mailbox NoOp
main = S.map (view actions.address) (S.foldp update model actions.signal)
