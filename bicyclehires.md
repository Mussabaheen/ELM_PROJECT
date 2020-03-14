---
elm:
  dependencies:
    gicentre/elm-vegalite: latest
---

```elm {l=hidden}
import VegaLite exposing (..)
```

```elm {v}
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
```

```

```
