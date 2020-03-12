---
elm:
  dependencies:
    gicentre/elm-vegalite: latest
---

```elm {l=hidden}
import VegaLite exposing (..)
```

```elm {v}
attendance : Spec
attendance =
    let
        cfg =
            configure
                << configuration (coView [ vicoStroke Nothing ])
                << configuration (coAxis [ axcoTicks False, axcoDomain False, axcoLabelAngle 0 ])

        data =
            dataFromUrl "https://gicentre.github.io/data/attendance.csv"

        enc =
            encoding
                << position X [ pName "session", pOrdinal ]
                << position Y
                    [ pName "attendance"
                    , pQuant
                    , pStack stCenter -- Stacked from the centre not bottom.
                    , pAxis []
                    ]
                << detail [ dName "id", dNominal ]
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
