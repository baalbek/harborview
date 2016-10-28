
import Json.Decode as JD
import Html.Events as HE
import Html exposing (Html,div,text,select,option,text,p)
import Html.App as App
import Html.Attributes as HA

main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

type alias Model = 
    { yax : Int }

type Msg
    = Jada  
    | Neida 

init : ( Model, Cmd Msg )
init = ( Model 5, Cmd.none )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model = ( model, Cmd.none )

targetSelectedIndex = JD.at ["target", "selectedIndex"] JD.int

view : Model -> Html Msg
view model =
  let
    selectEvent = HE.on "change" targetSelectedIndex
                  (S.message address << Select)
  in
    div []
       [ select [ HA.class "form-control"
                , HA.size 1
         -- ,HA.style [ ("visibility", "hidden") ]     
       ]

            [ option [] [ text "1 youtertertj" ]
            , option [] [ text "2 s32r23fwrf" ]
            , option [] [ text "3 w23423sdffdsfs" ]
            ]
     ]

subscriptions : Model -> Sub Msg
subscriptions model = Sub.none
