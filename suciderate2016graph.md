---
elm:
  dependencies:
    gicentre/elm-vegalite: latest
---

```elm {l=hidden}
import VegaLite exposing (..)
```

```elm {v}
suicide : Spec
suicide =
    let
        cfg =
            configure
                << configuration (coView [ vicoStroke Nothing ])
                << configuration (coAxis [ axcoTicks False, axcoDomain False, axcoLabelAngle 0 ])

        data =
            dataFromUrl "suicideratesandgdp2016.csv"

        enc =
            encoding
                << position X [ pName "SuicideRate_2016", pQuant ]
                << position Y
                    [ pName "CountryName"
                    , pNominal
                    ]
                << detail [ dName "SuicideRate_2000", dNominal ]
                << color [ mName "cohort", mOrdinal, mScale [ scScheme "dark2" [] ] ]
    in
    toVegaLite
        [ width 600
        , height 300
        , cfg []
        , data [ parse [ ( "session", foNum ) ] ] -- Ensure 'session' column treated as number
        , enc []
        , area
            [ maLine (lmMarker []) -- Add lines around each area 'stream'
            , maInterpolate miMonotone -- Monotone interpolation gives curved lines
            ]
        ]
```

```

```
