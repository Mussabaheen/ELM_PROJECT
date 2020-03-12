---
elm:
  dependencies:
    gicentre/elm-vegalite: latest
---

```elm {l=hidden}
import VegaLite exposing (..)


data : Data
data =
    dataFromUrl "unemploymentbycountry.csv" []
```

unemployment : Spec
unemployment =
let
enc =
encoding
<< position X [ pName "country", pTemporal, pAxis [ axFormat "%Y" ] ]
<< position Y [ pName "Healthylife\nexpectancy", pQuant, pTitle "lifeexceptancy" ]
in
toVegaLite [ width 400, data, line [ maStroke "darkBlue" ], enc [] ]
