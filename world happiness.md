---
elm:
  dependencies:
    gicentre/elm-vegalite: latest
---

```elm {l=hidden}
import VegaLite exposing (..)
```

data : Data
data =
dataFromUrl "worldhappinessreport" []

    interaction : Spec

interaction =
let
sel =
selection << select "Happiness" seInterval []

        enc =
            encoding
                << position X [ pName "Country", pQuant ]
                << position Y [ pName "Healthy life", pQuant ]
                << color
                    [ mSelectionCondition (selectionName "Happiness")
                        [ mName "Healthy life", mOrdinal ]
                        [ mStr "grey" ]
                    ]
    in
    toVegaLite [ width 300, height 150, data, point [], sel [], enc [] ]
