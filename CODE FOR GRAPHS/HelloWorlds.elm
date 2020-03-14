port module HelloWorlds exposing (elmToJS)

import Platform
import VegaLite exposing (..)


myFirstVis : Spec
myFirstVis =
    let
      sel =
        selection
            << select "picked" seSingle []

      enc =
        encoding
            << position X [ pName "CountryName", pNominal ]
            << position Y [ pName "sucideandgdp", pQuant]
            << color
                [ mSelectionCondition (selectionName "picked")
                      [ mName "GDPorSUCIDE", mNominal ]
                    [ mStr "grey" ]
                ]
            <<tooltips [[  tName "CountryName",tNominal,tTitle "Country Name: "],[tName "sucideandgdp",tNominal,tTitle "SUCIDE(Orange)&GDP(Blue):"]]

    in
      toVegaLite
      [ dataFromUrl "https://raw.githubusercontent.com/Mussabaheen/ELM_PROJECT/master/cleaned_2016_GDP_SUCIDE_done.csv" []
    , bar []
    , enc []
    , sel []
      ]


mySecondVis : Spec
mySecondVis =
    let
      sel=
        selection
            << select "tapped" seSingle [
               seFields [ "Region" ]

              
            ]
      enc =
        encoding
            << position X [ pName "Country Name", pNominal ,pTitle ""]
            << position Y [ pName "2016", pQuant,pTitle "UnEmployement Rate" ]
            <<color
                [ mSelectionCondition (selectionName "tapped")
                    [ mName "Region" ]
                    [ mStr "grey" ]
                ]
            <<tooltips [[  tName "2016",tQuant,tTitle "Sucide Rate: "],[tName "Country Name",tNominal]]

    in
      toVegaLite
      [ dataFromUrl "https://raw.githubusercontent.com/Mussabaheen/ELM_PROJECT/master/unemploymentbycountry.csv" []
    , bar []
    , enc []
    , sel []

      ]

mythirdVis : Spec
mythirdVis =
    let
      sel=
        selection
            << select "tapped_1" seInterval [ seEncodings [ chX ] ] 
      enc =
        encoding
            << position X [ pName "Country (region)", pNominal,pSort [ soByField "Ladder" opMean, soAscending ] ]
            <<color
                [ mSelectionCondition (selectionName "tapped_1")
                    [ mName "Ladder", mQuant ]
                    [ mStr "grey" ]
                ]
    in
      toVegaLite
      [ dataFromUrl "https://raw.githubusercontent.com/Mussabaheen/ELM_PROJECT/master/worldhappinessreport.csv" []
    , rect []
    , enc []
    , sel [],
    height 100

      ]



{- This list comprises tuples of the label for each embedded visualization (here vis1, vis2 etc.)
   and corresponding Vega-Lite specification.
   It assembles all the listed specs into a single JSON object.
-}


mySpecs : Spec
mySpecs =
    combineSpecs
        [ ( "vis1", myFirstVis )
        , ( "vis2", mySecondVis )
        , ( "vis3", mythirdVis )
        ]



{- The code below is boilerplate for creating a headless Elm module that opens
   an outgoing port to Javascript and sends the specs to it.
-}


main : Program () Spec msg
main =
    Platform.worker
        { init = always ( mySpecs, elmToJS mySpecs )
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = always Sub.none
        }


port elmToJS : Spec -> Cmd msg
