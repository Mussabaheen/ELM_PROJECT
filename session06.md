---
id: litvis

narrative-schemas:
  - ../narrative-schemas/teaching.yml

elm:
  dependencies:
    gicentre/elm-vegalite: latest
---

@import "../css/datavis.less"

```elm {l=hidden}
import VegaLite exposing (..)
```

<!-- Everything above this line should probably be left untouched. -->

# Session 6: Building Interaction

## Table of Contents

1. [Introduction](#1-introduction)
2. [A Grammar of Interaction](#2-a-grammar-of-interaction)
3. [Specifying a Selection](#3-specifying-a-selection)
4. [Responding to a Selection](#4-responding-to-a-selection)
5. [Conclusions](#5-conclusions)
6. [Recommending Reading](#6-recommended-reading)
7. [Practical Exercises](#7-practical-exercises)

{(aim|}

This session is designed to show how interaction between the user and graphical representation can improve the power of the data visualization process. It provides details on the _grammar of interaction_ in Litvis / Vega-Lite for capturing mouse and keyboard input and allowing data shaping and graphical encoding to respond to interactions.

By the end of this session you should be able to:

- Identify Shneiderman's 7 task-domain information actions and use them to shape the design of your own data visualizations.
- Specify your own interactive visualizations and embed them in a litvis document.
- Locate your own interaction specifications in the _grammar of interaction_ of Satyanarayan et al.
- Specify a variety of interaction _selections_ in Vega-Lite/litvis including directly with marks and indirectly via GUI input components.
- Specify a variety of _selection responses_ in Vega-Lite/litvis including conditional encoding, selection filtering and scale binding.

{|aim)}

---

## 1. Introduction

In his highly influential paper, [Shneiderman (1996)](#references) suggested that all successful information visualization applications he had developed over the previous decade involved the user participating in a similar set of activities. He summarised these with what he called a _visual information seeking mantra:_

> Overview first, zoom and filter, then details-on-demand
>
> Overview first, zoom and filter, then details-on-demand
>
> Overview first, zoom and filter, then details-on-demand
>
> Overview first, zoom and filter, then details-on-demand
>
> Overview first, zoom and filter, then details-on-demand

He went on to suggest that these were part of seven related "task-domain information actions" undertaken by users of successful data visualizations (quoted from Shneiderman (1996), p.2):

- **Overview**: gain an overview of the entire collection [of data].
- **Zoom**: zoom in on items of interest.
- **Filter**: filter out uninteresting items.
- **Details-on-demand**: select an item or group and get details when needed.
- **Relate**: View relationships among items.
- **History**: Keep a history of actions to support undo, replay and progressive refinement.
- **Extract**: Allow extraction of sub-collections and of the query parameters.

Note that unlike Wilkinson's _Grammar of Graphics_, these activities represent the tasks the visualization _user_ faces, not the visualization designer. Shneiderman's assertion was that designers should support these stages of information seeking when creating visualization systems. Central to Shneiderman’s seven activities is the notion of _interaction_ – the appearance and use of the visualization will change in response to control by the user. This session considers some of the ways in which interaction may be used to make your data visualization more effective.

{(task|}

Consider this [interactive visualization example](http://www.gicentre.org/pbp2015/). It shows the results of 6000 entrants in a bicycle race taking place over four days and 1250km from Paris to Brest and back. You can see the progress of individual riders by entering their IDs in the text box. Some examples to try include rider `A100`, rider `E103` and rider `F220`.

![Paris-Brest-Paris 2015](https://staff.city.ac.uk/~jwo/datavis2020/session06/images/pbp2015.jpg)

How many of Shneiderman's 7 tasks are supported by the visualization? What role does interaction play in supporting them (if at all)? How would you improve the design to support the tasks more effectively?

For more details of the design approach used here, see [Wood, 2015](#references).

{|task)}

As a simple, but only partial, way of following Shneiderman's mantra in your own litvis visualizations, adding `interactive` to any visualization code block header and adding [maTooltip ttEncoding](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#ttEncoding) will give you 'tooltips' for free that display the details of the data being encoded via the mark under the mouse pointer. For example:

```elm {v interactive}
cycleHires : Spec
cycleHires =
    let
        data =
            dataFromUrl "https://gicentre.github.io/data/bicycleHiresLondon.csv"

        enc =
            encoding
                << position X [ pName "Month", pTemporal, pAxis [ axGrid False, axTitle "" ] ]
                << position Y [ pName "NumberOfHires", pQuant, pAxis [ axGrid False ] ]
    in
    toVegaLite [ width 540, data [], enc [], bar [ maTooltip ttEncoding ] ]
```

Note that unless otherwise specified, the tooltip will display the data values that have been encoded via the [encoding](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#encoding) function (in the example above `Month` and `NumberOfHires`). If you wish to set what is displayed in a tooltip explicitly, you can encode data fields via the [tooltips](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#tooltips) channel. For example:

```elm {l v interactive highlight=[11,12,13,14]}
cycleHiresCustomTT : Spec
cycleHiresCustomTT =
    let
        data =
            dataFromUrl "https://gicentre.github.io/data/bicycleHiresLondon.csv"

        enc =
            encoding
                << position X [ pName "Month", pTemporal, pAxis [ axGrid False, axTitle "" ] ]
                << position Y [ pName "NumberOfHires", pQuant, pAxis [ axGrid False ] ]
                << tooltips
                    [ [ tName "Month", tTemporal, tFormat "%B %Y" ]
                    , [ tName "AvHireTime", tQuant ]
                    ]
    in
    toVegaLite [ width 540, data [], enc [], bar [] ]
```

Note also the use of [d3 text formatting codes](https://github.com/d3/d3-time-format#locale_format) in line 12 to show a more friendly month-year format for the temporal data.

{(infobox|} If you want any form of interaction to take place in your visualization, such as those in this session, you should always add the `interactive` tag to the code block header that generates the specification. The only disadvantage of making a code block `interactive` is that it stops the formatted output from being displayed when saving as a PDF or web page (via right-click of the preview window).{|infobox)}

Shneiderman's seven task-domain information actions (TDIAs) can provide useful guidelines for the design of interactive visualizations, even if you choose not to implement support for all seven actions. To ensure you at least consider all seven actions in your design, we can steer a design rationale with a [TDIA narrative schema](https://staff.city.ac.uk/~jwo/datavis2020/narrative-schemas/tdia.yml) and an [example TDIA litvis template](https://staff.city.ac.uk/~jwo/datavis2020/session06/tdiaExample.md).

## 2. A Grammar of Interaction

Wilkinson's _Grammar of Graphics_ captures the transformations necessary to specify static data-driven visualizations, but it does not formally account for the role interaction can play in shaping those transformations. [Satyanarayan et al (2017)](#6-recommended-reading) argue for a complementary _grammar of interaction_ that specifies the additional transformations brought about through interaction. This grammar is used by Vega-Lite (and therefore litvis) to provide a structured way of introducing interaction into your specifications.

At the heart of this interaction grammar are two processes:

- **making a selection** by allowing a user to identify elements of a visualization to choose for special treatment. This selection might be made directly by dragging or clicking the mouse pointer over some marks representing data values, or indirectly via some graphical user interface input components (sliders, radio buttons, drop-down lists etc.). Additionally, a selection may be _transformed_, for example so that selecting a single point is used to extend the selection to all data items that share a common data value with the selected point.

* To be useful, once a selection has been made we need to define how to **respond to the selection**. Responses might include _filtering_ only those items selected, or _highlighting_ selected items, or _binding_ the selection to a scale to allow zooming and panning. Additionally, the _selection mark_ itself may be rendered directly to provide visual feedback to support interaction.

![A grammar of interactive graphics](https://staff.city.ac.uk/~jwo/datavis2020/session06/images/grammarOfInteractiveGraphics.png?q=0)

More formally, [Satyanarayan et al (2017), §4.1](#6-recommended-reading) define the grammar of selection as an 8-tuple:

> _selection := (name, type, predicate, domain | range, event, init, transforms, resolve)_

where

- _name_ is the identifier we give to the selection so it can be referred to in a specification
- _type_ determines how many items may be selected; options include [seSingle](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seSingle), [seMulti](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seMulti) and [seInterval](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seInterval).
- _predicate_ (a function that evaluates to either true or false) determines whether or not a data item has been selected.
- _domain | range_ determines whether the selection applies to 'data space' (_domain_) or 'graphic space' (_range_). Usually, selections are in the domain, which makes linking selections across multiple views much easier, but occasionally range selections can useful, such as picking colours from a legend.
- _event_ is the input modality used to drive the selection, such as mouse click, touch event, trackpad gesture, keyboard input etc. (controllable via [seOn](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seOn))
- _init_ describes the initial selection before any input is provided. This allows, for example, a selection to be initially empty ([seEmpty](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seEmpty)), or initially containing the entire dataset (default), or some partial selection ([seInit](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seInit)).
- _transforms_ manipulate the selection through _projection_ ([seFields](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seFields)), _toggling_ ([seToggle](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seToggle)), _translation_ ([seTranslate](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seTranslate)), _zooming_ ([seZoom](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seZoom)) and _proximity detection_ ([seNearest](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seNearest)), allowing a selection to be extended beyond its initial interaction with a data point.
- _resolve_ describes how multiple selections may be combined ([seResolve](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seResolve)).

Before we look in more detail at how we specify this grammar through Vega-Lite, consider this example of how we might allow an [interval selection](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seInterval) to be added to a scatterplot, to provide a means of highlighting a subset of points:

```elm {l v interactive highlight=[7-9,16-19,25]}
cycleHiresInterval : Spec
cycleHiresInterval =
    let
        data =
            dataFromUrl "https://gicentre.github.io/data/bicycleHiresLondon.csv"

        sel =
            selection
                << select "myBrush" seInterval [ seEmpty ]

        enc =
            encoding
                << position X [ pName "NumberOfHires", pQuant ]
                << position Y [ pName "AvHireTime", pQuant ]
                << color
                    [ mSelectionCondition (selectionName "myBrush")
                        [ mStr "red" ]
                        [ mStr "lightgrey" ]
                    ]
    in
    toVegaLite
        [ width 400
        , height 400
        , data []
        , sel []
        , enc []
        , point []
        ]
```

{(task|}Try dragging a rectangle of the chart above to make a selection. Once created, you should be able to drag the interval selection around with the mouse and change its size with the mousewheel (or equivalent trackpad gesture).{|task)}

We add a selection with the [selection](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#selection) function and specify the type of selection with [select](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#select), here specifying an [seInterval](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seInterval) type. We give the selection a name (here called `myBrush`) so it can be referred to elsewhere in our specification and set the selection to be initially empty (with [seEmpty](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seEmpty)).

In the example, the response to the selection _predicate_ is provided in the colour encoding, specifically with [mSelectionCondition](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#mSelectionCondition), that allows us to specify not just one encoding rule, but two alternatives, depending on whether or not an item to be encoded has been selected. After specifying the name of the selection to respond to (`myBrush`), the second and third parameters to `mSelectionCondition` are lists of encoding rules to apply when selected (second parameter) and when not selected (third parameter).

## 3. Specifying a Selection

We can allow the user to select parts of a dataset to manipulate in a variety of ways. Some design questions to consider:

- Should interaction allow selection of a single data point, multiple discrete data points or a continuous interval enclosing data points?
- Should selection be directly with the data representation (e.g. clicking on points in a scatterplot), or indirectly via GUI input components (e.g. selecting items from a menu or list of radio buttons)?

### Direct Interaction

Here the user clicks and drags directly over the visualization to select data values. For example, suppose we wish to show reported crime over time, subdivided by crime type which we encode with colour. We might allow any given crime type to be highlighted by clicking directly on the line representing it:

```elm {l highlight=[21-24,26-29]}
crimeData =
    dataFromUrl "https://gicentre.github.io/data/westMidlands/westMidsCrimesAggregated.tsv"


crimeColours =
    categoricalDomainMap
        [ ( "Anti-social behaviour", "rgb(59,118,175)" )
        , ( "Burglary", "rgb(81,157,62)" )
        , ( "Criminal damage and arson", "rgb(141,106,184)" )
        , ( "Drugs", "rgb(239,133,55)" )
        , ( "Robbery", "rgb(132,88,78)" )
        , ( "Vehicle crime", "rgb(213,126,190)" )
        ]


encHighlight =
    encoding
        << position X [ pName "month", pTemporal, pTitle "" ]
        << position Y [ pName "reportedCrimes", pQuant ]
        << color
            [ mSelectionCondition (selectionName "mySelection")
                [ mName "crimeType", mNominal, mScale crimeColours ]
                [ mStr "black" ]
            ]
        << opacity
            [ mSelectionCondition (selectionName "mySelection")
                [ mNum 1 ]
                [ mNum 0.1 ]
            ]
```

_(The data, colour and encoding functions are stored in their own code block above so we can reuse them in multiple examples below.)_

```elm {l v interactive highlight=[4-6,13]}
singleSelection : Spec
singleSelection =
    let
        sel =
            selection
                << select "mySelection" seSingle []
    in
    toVegaLite
        [ width 540
        , crimeData [] -- Data specified in code block above
        , encHighlight [] -- Encoding specified in code block above
        , line [ maInterpolate miMonotone ]
        , sel []
        ]
```

By setting the selection type to [seSingle](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seSingle) only one mark at a time may be selected. To allow multiple marks to be selected (holding down the shift key while clicking), simply replace `seSingle` with [seMulti](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seMulti).

{(task|}Check the line selection behaviour in the example above by clicking on individual lines. Try replacing `seSingle` with `seMulti` and confirm that multiple selections can be made by clicking on lines while holding down the shift key. {|task)}

This form of selection will work for any mark type, selecting the mark directly under the mouse. If we change the mark from [line](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#line) to [circle](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#circle) and clicking on a mark now just highlights an individual circle.

```elm {l v interactive highlight=12}
pointSelection : Spec
pointSelection =
    let
        sel =
            selection
                << select "mySelection" seSingle [ seNearest True ]
    in
    toVegaLite
        [ width 540
        , crimeData [] -- Data specified in separate code block
        , encHighlight [] -- Encoding specified in separate code block
        , circle []
        , sel []
        ]
```

This is problematic for a couple of reasons. Firstly, you have to be quite precise when clicking a point. If the pointer is not quite over a circle, the selection is assumed to apply to the entire dataset. Secondly, highlighting a single point, in this case at least, is not very helpful. Both problems can be addressed by _projecting_ the selection.

We can solve the first problem by adding the option [seNearest True](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seNearest) to the selection specification:

```elm
  << select "mySelection" seSingle [ seNearest True ]
```

This will project the selection under the mouse pointer to the mark nearest to its location, rather than relying on a (small) mark being clicked on in its precise location.

{(task|}Try adding `seNearest True` to the example above and observe the effect on interaction.{|task)}

The second problem can be addressed by projecting the selection from just the single point to all data points that share some common characteristic. We can do this by specifying the fields (data variables) onto which the selection is to be projected. For example, to select all points with the same crime type as the selected point:

```elm {l v interactive highlight=6}
domainProjection : Spec
domainProjection =
    let
        sel =
            selection
                << select "mySelection" seSingle [ seNearest True, seFields [ "month" ] ]
    in
    toVegaLite
        [ width 540
        , crimeData [] -- Data specified in separate code block
        , encHighlight [] -- Encoding specified in separate code block
        , circle []
        , sel []
        ]
```

{(task|} How would you change the projection so that all crime types in the same month as the selected data point are highlighted? Try amending the example above to do this.{|task)}

As well as projecting a selection across the data _domain_, we can also project it across a graphic _range_ with [seEncodings](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seEncodings). This allows us to identify any position channels onto which we project the selection. For example, by specifying `chX` as a selection encoding, we are stating we wish selection interval to be constrained only in the `X` position channel (rather than the default `X` and `Y`), allowing the entire `Y` channel to be selected. This is usefully combined with an [seInterval](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seInterval) selection to create a time-interval selector:

```elm {l v interactive highlight=6}
rangeProjection : Spec
rangeProjection =
    let
        sel =
            selection
                << select "mySelection" seInterval [ seEncodings [ chX ] ]
    in
    toVegaLite
        [ width 540
        , crimeData [] -- Data specified in separate code block
        , encHighlight [] -- Encoding specified in separate code block
        , circle []
        , sel []
        ]
```

{(task|}Test this interaction specification works by dragging over a range in the chart. In what circumstances might this form of selection be useful?{|task)}

#### Customising selection interaction

The examples above all use Vega-Lite's default modes of interaction. For example, [seSingle](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seSingle) allows the selection of single marks by clicking on a mark, [seMulti](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#Multi) allows multiple selections to be made by holding the shift-key down while clicking, and [seInterval](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seInterval) requires the mouse to be dragged to form a selection rectangle.

We can exercise more precise selection interaction to override these defaults by specifying an [event stream](https://vega.github.io/vega/docs/event-streams/) as a string provided to [seOn](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seOn). For example, to create a 'paintbrush' effect that highlights data points under the mouse pointer position while holding down the shift key, we could do the following:

```elm {l v interactive highlight=[6-8]}
paintbrushExample : Spec
paintbrushExample =
    let
        sel =
            selection
                << select "mySelection"
                    seMulti
                    [ seOn "mouseover", seNearest True, seEmpty ]
    in
    toVegaLite
        [ width 540
        , crimeData [] -- Data specified in separate code block
        , encHighlight [] -- Encoding specified in separate code block
        , circle []
        , sel []
        ]
```

{(task|}Test this interaction specification works by moving the mouse pointer over points with the shift-key held down. In what circumstances might this form of selection be useful and an advantage over a rectangular interval selection?{|task)}

### Indirect Interaction with Input Components

Direct interaction with marks representing data points is intuitive and can allow precise selection of individual data points. However, as can be seen when attempting to select values from the _Drugs_, _Robbery_ and other clustered points/lines in the examples above, this can sometimes be quite tricky to do.

An alternative means of selection is to do so indirectly via an input component such as a button or slider. We do this by _binding_ an input component to a data field with [seBind](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seBind). For example, here we allow 'radio buttons' to be used to select different crime types:

```elm {l v interactive highlight=[10-22]}
selRadio : Spec
selRadio =
    let
        sel =
            selection
                << select "mySelection"
                    seSingle
                    [ seFields [ "crimeType" ]
                    , seNearest True
                    , seBind
                        [ iRange "crimeType"
                            [ inOptions
                                [ "Anti-social behaviour"
                                , "Criminal damage and arson"
                                , "Drugs"
                                , "Robbery"
                                , "Vehicle crime"
                                ]
                            ]
                        ]
                    ]
    in
    toVegaLite
        [ width 540
        , crimeData [] -- Data specified in separate code block
        , encHighlight [] -- Encoding specified in separate code block
        , circle []
        , sel []
        ]
```

{(task|}Try clicking on the radio buttons above to select a crime type. Also try clicking on one of the data points directly to confirm that the binding is two-way.{|task)}

To bind to an input component with [seBind](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seBind), we name the type of component (e.g. [iRadio](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#iRadio) for radio buttons, [iRange](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#iRange) for range sliders, [iSelect](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#iSelect) for a drop-down list), followed by the name of the data field we wish to bind it to (`crimeType` in the example above). This is then followed by a list any options to customise the appearance of the input component. In the example above, that customisation includes the display label (_"Type of crime"_) and the list of radio buttons to display. The name of each should match a value to select in the data field.

{(task|}Try replacing the function `iRadio` with `iSelect` in the example above (nothing else need change) and observe the effect. Which of these two input components do you think works best? Why?{|task)}

{(infobox|}

The appearance of input components like radio buttons and sliders can be controlled via a _stylesheet_ (in this document linked as `../css/datavis.less`). For example, to increase the spacing between input elements and to standardise the length of sliders, we might add:

```css
input[type="radio"],
input[type="checkbox"],
input[type="select"],
input[type="range"] {
  margin-left: 1em;
}

input[type="range"] {
  min-width: 120px;
  max-width: 120px;
}
```

You may wish to add these stylings to your own copy of `datavis.less` to improve the formatting of common input components.

{|infobox)}

Radio buttons and drop-down selections work reasonably effectively for discrete categories, but less so for selections from continuous or ordered data. In such cases range sliders (identified with [iRange](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#iRange)) can be more useful. Like good visualization design, the qualities of the slider should reflect the qualities of the selection being made (ordered, bound between a minimum and maximum and possibly continuous).

For example, suppose we wish to make a temporal selection from the crime data. We could use an input slider to select a date. Or possibly more usefully, select a quarter year period and _project_ the selection across all similar quarters in the data. That way we can make direct comparison between the same quarter in subsequent years:

```elm {l v interactive highlight=[4-6,12-18]}
selQuarter : Spec
selQuarter =
    let
        trans =
            transform
                << calculateAs "quarter(datum.month)" "quarter"

        sel =
            selection
                << select "mySelection"
                    seSingle
                    [ seFields [ "quarter" ]
                    , seNearest True
                    , seBind
                        [ iRange "quarter"
                            [ inName "Quarter to highlight", inMin 1, inMax 4, inStep 1 ]
                        ]
                    ]
    in
    toVegaLite
        [ width 540
        , trans []
        , crimeData [] -- Data specified in separate code block
        , encHighlight [] -- Encoding specified in separate code block
        , circle []
        , sel []
        ]
```

To do this we have performed some minor data shaping by deriving a new data field `quarter` from the data using a [date-time expression](https://vega.github.io/vega/docs/expressions/#datetime-functions). When specifying an [iRange](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#iRange) we can optionally specify the minimum ([inMin](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#inMin)) and maximum ([inMax](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#inMax)) values permitted by the slider along with the step size ([inStep](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#inStep)) of each slider increment .

## 4. Responding to a Selection

So far, all the selections we have explored have been used to generate a [conditional mark encoding](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#mSelectionCondition), allowing us to provide two alternative mark encodings depending on whether or not a mark has been selected. But there are other types of response to a selection we could also consider, enriching the interaction design space available to us.

- _conditional encoding_ : Apply different channel encodings depending on whether a data item has been selected (as seen above).
- _scale binding_ : Bind the selection to a position scale.
- _selection filtering_ : Only show the items selected in one or more views.

### Scale Binding

We have already seen how the grammar of interaction allows a _binding_ between some interaction event and some aspect of the visualization specification. So far we have seen this in action when binding an input component, for example a slider, to some data field.

We can also bind an interaction to the _scale_ stage of Wilkinson's Grammar of Graphics with [seBindScales](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seBindScales). This becomes particularly useful when binding an interval selection to a position scale. For example, we can control the time interval shown in the crime chart by binding the `X` position scale to an interval selection:

```elm {l v interactive highlight=[6,18]}
selDateInterval : Spec
selDateInterval =
    let
        sel =
            selection
                << select "mySelection" seInterval [ seBindScales, seEncodings [ chX ] ]

        enc =
            encoding
                << position X [ pName "month", pTemporal, pTitle "" ]
                << position Y [ pName "reportedCrimes", pQuant ]
                << color [ mName "crimeType", mNominal, mScale crimeColours ]
    in
    toVegaLite
        [ width 540
        , crimeData [] -- Data specified in separate code block
        , enc []
        , line [ maInterpolate miMonotone, maPoint (pmMarker []) ]
        , sel []
        ]
```

{(task|}Try panning and zooming the temporal scale by using the mouse wheel (or equivalent trackpad gesture) to zoom and drag to pan. Double-clicking on a zoomed view should return it to the default (unzoomed) scaling.{|task)}

In our particular example this zooming along one position axis doesn't really help the overcrowding problem produced by the contrasting magnitudes of 'anti-social behaviour' and other crime types. We can overcome this by allowing binding of both position scales, which conveniently is the default encoding for an interval selection:

```elm {l v interactive highlight=[6]}
selZoom : Spec
selZoom =
    let
        sel =
            selection
                << select "mySelection" seInterval [ seBindScales ]

        enc =
            encoding
                << position X [ pName "month", pTemporal, pTitle "" ]
                << position Y [ pName "reportedCrimes", pQuant ]
                << color [ mName "crimeType", mNominal, mScale crimeColours ]
    in
    toVegaLite
        [ width 540
        , crimeData [] -- Data specified in separate code block
        , enc []
        , line [ maPoint (pmMarker []) ]
        , sel []
        ]
```

{(task|}This two-dimensional zooming helps to focus 'details on demand', but loses the overview of the trends over time when zoomed in. Modify the specification above so that zooming only affects "reported crimes" and not the dates on the X position channel. {|task)}

### Selection Filtering

In the last session we saw how to [filter](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#filter) data based on some predicate expression (i.e. one that evaluated to true or false). If we replace such expressions with a selection predicate using [fiSelection](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#fiSelection), we can instead filter based on only those items selected interactively.

In the example below, we apply a selection-based filter to the bicycle hire data we considered way back in session 1:

```elm {l v interactive highlight=[11-13,20,25]}
cycleHiresFilter : Spec
cycleHiresFilter =
    let
        data =
            dataFromUrl "https://gicentre.github.io/data/bicycleHiresLondon.csv"

        sel =
            selection
                << select "myBrush" seInterval []

        trans =
            transform
                << filter (fiSelection "myBrush")

        enc =
            encoding
                << position X
                    [ pName "NumberOfHires"
                    , pQuant
                    , pScale [ scDomain (doNums [ 0, 1300000 ]) ]
                    ]
                << position Y
                    [ pName "AvHireTime"
                    , pQuant
                    , pScale [ scDomain (doNums [ 0, 28 ]) ]
                    ]
    in
    toVegaLite [ width 350, height 350, data [], sel [], trans [], enc [], point [] ]
```

{(task|}Before you interact with this visualization, what effect do anticipate will result from dragging a rectangle over the scatterplot? The `pScale` lines ensure that the data domain for each axis remains fixed between 0 - 1,300,00 and 0 - 28 respectively. Why do you think this is necessary?{|task)}

Simply selection-filtering in a single view of a dataset isn't very useful. The benefits come when we select in one view of a dataset and filter data in another. We will consider multiple views in more detail in the next session when we look at view composition, but for now, here are some applications of selection-filtering:

#### (a) Interactive Legend

Rather than use the default legend created when we encode a data field with a non-positional channel, we can create an interactive 'chart' that both acts as a legend and allows selections to be made upon it.

Returning to our crime example, we can do this by specifying a chart that comprises just one symbol for each crime category in the dataset. By placing the legend creation specification and selection into its own function, we can use this to create an interactive legend for any categorical variable:

```elm {l highlight=21}
interactiveLegend : String -> String -> Spec
interactiveLegend field selName =
    let
        enc =
            encoding
                -- Just encode in the Y position direction to create column of marks
                << position Y
                    [ pName field
                    , pNominal
                    , pAxis [ axTitle "", axDomain False, axTicks False ]
                    ]
                << color
                    [ mSelectionCondition (selectionName selName)
                        [ mName field, mNominal, mScale crimeColours, mLegend [] ]
                        [ mStr "lightgrey" ]
                    ]

        sel =
            selection
                -- Project selection to all matching values in the colour channel
                << select selName seMulti [ seEncodings [ chColor ] ]
    in
    asSpec [ sel [], enc [], square [ maSize 120, maOpacity 1 ] ]
```

In the main chart, we filter categories according to those selected in the legend (shift-click for multiple selections):

```elm {l v interactive highlight=[6,14,15,24]}
crimesWithInteractiveLegend : Spec
crimesWithInteractiveLegend =
    let
        trans =
            transform
                << filter (fiSelection "legendSel")

        enc =
            encoding
                << position X [ pName "month", pTemporal, pTitle "" ]
                << position Y [ pName "reportedCrimes", pQuant ]
                << color [ mName "crimeType", mNominal, mScale crimeColours, mLegend [] ]

        chartSpec =
            asSpec [ width 540, trans [], enc [], line [ maInterpolate miMonotone ] ]

        cfg =
            configure
                << configuration (coView [ vicoStroke Nothing ])
    in
    toVegaLite
        [ cfg []
        , crimeData []
        , hConcat [ chartSpec, interactiveLegend "crimeType" "legendSel" ]
        ]
```

The two charts are combined using [horizontal concatentation](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#hConcat), which we will consider in more detail in the next session.

{(task|}Try clicking / shift-clicking on the coloured squares to see the effect if filtering in the main chart. Note that unlike conditional encoding, filtering results in dynamic readjustment of the vertical axis range so we can see trends in the low-volume crimes like "Drugs" and "Robbery". {|task)}

{(infobox|}

If you want to create a simpler form of interactive legend that performs a selection from the legend but does not filter, you can bind the legend to a plot with [seBindLegend](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seBindLegend). This allows you to create conditional encoding based on the legend-selection:

```elm {l v interactive highlight=[6]}
crimesWithInteractiveBindLegend : Spec
crimesWithInteractiveBindLegend =
    let
        sel =
            selection
                << select "mySelection" seSingle [ seBindLegend [ blField "crimeType" ] ]
    in
    toVegaLite [ width 540, crimeData [], sel [], encHighlight [], circle [] ]
```

{|infobox)}

#### (b) Range filters

In the example below, we use [iRange](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#iRange) to create a pair of range sliders that allow a minimum and maximum crime rate to be selected. Their values are initialised with [seInit](https://package.elm-lang.org/packages/gicentre/elm-vegalite/latest/VegaLite#seInit) to ensure that when first viewed, the sliders are in sensible positions. Range sliders can act as an alternative to a direct interval selection bound to a position scale.

Note the filter expression has access to the values of the two sliders via the names `minSlider_minReported` and `maxSlider_maxReported`, ie. a name comprising the selection name and range selector name separated by an underscore character.

```elm {l v interactive highlight=[12-21,25]}
rangeFilterExample : Spec
rangeFilterExample =
    let
        enc =
            encoding
                << position X [ pName "month", pTemporal ]
                << position Y [ pName "reportedCrimes", pQuant ]
                << color [ mName "crimeType", mNominal, mScale crimeColours ]

        sel =
            selection
                << select "maxSlider"
                    seSingle
                    [ seInit [ ( "maxReported", num 14000 ) ]
                    , seBind [ iRange "maxReported" [ inName "Max", inMin 400, inMax 14000 ] ]
                    ]
                << select "minSlider"
                    seSingle
                    [ seInit [ ( "minReported", num 0 ) ]
                    , seBind [ iRange "minReported" [ inName "Min", inMax 12800 ] ]
                    ]

        trans =
            transform
                << filter (fiExpr "datum.reportedCrimes >= minSlider_minReported && maxSlider_maxReported >= datum.reportedCrimes")
    in
    toVegaLite [ width 540, crimeData [], trans [], sel [], enc [], circle [] ]
```

{(task|}Observe the effect of moving the sliders. In what circumstances would selecting a threshold like this be useful? {|task)}

This implementation isn't without problems in that [currently](https://github.com/vega/vega-lite/issues/4631) it is possible to set a minimum threshold greater than the maximum threshold.

#### (c) Cross Filtering

Finally we implement _cross filtering_ between views showing monthly London bicycle hire data. The highlighted bars are the filtered data, overlaid on the unfiltered data.

```elm {l v interactive}
crossFilter : Spec
crossFilter =
    let
        data =
            dataFromUrl "https://gicentre.github.io/data/bicycleHiresLondon.csv"

        sel =
            selection
                << select "myBrush" seInterval [ seEncodings [ chX ], seEmpty ]

        trans =
            transform
                << filter (fiSelection "myBrush")

        enc =
            encoding
                << position X [ pRepeat arColumn, pQuant, pBin [ biMaxBins 20 ] ]
                << position Y [ pAggregate opCount, pQuant ]

        specFull =
            asSpec [ width 250, sel [], enc [], bar [ maColor "rgb(117,82,60)" ] ]

        specFiltered =
            asSpec [ enc [], trans [], bar [ maColor "rgb(212,162,73)" ] ]
    in
    toVegaLite
        [ repeat [ columnFields [ "NumberOfHires", "AvHireTime" ] ]
        , specification (asSpec [ data [], layer [ specFull, specFiltered ] ])
        ]
```

{(task|}Try selecting one or more of the bars in one of the charts by dragging a rectangle to see the effect of cross filtering. In what circumstances might cross filtering be a useful in supporting data analysis?{|task)}

## 5. Conclusions

Interaction is an important part of the data visualization design 'space'. Because data visualization is essentially a human process, interaction allows the viewer to tailor their view of the data to match their own objectives/preferences. This is especially useful when you as a designer cannot be certain, what aspects of the data the user of your visualization would wish to emphasise.

Shneiderman's task-domain information actions (TDIAs) provide a useful guiding framework for considering the role of interaction to support users' tasks and should help you consider when, how and why you might include interaction in your own visualizations.

Equally, Satyanarayan's grammar of interaction provides a systematic way to consider how interaction can be specified. In particular it is useful to separate the actions of specifying a _selection_ and specifying a response to that selection.

One of the major benefits of interaction is in handling more complex views of data. This should become more apparent when we consider how to compose multiple views of a dataset, where interaction with one view can shape the appearance of other related views. We will consider how interaction can be combined with _view composition_ to create such multi-view designs in the next session.

## 6. Recommended Reading

**Kirk, A.** (2019) Chapter 7: _Interactivity_, pp.203-230, in [Data Visualisation: A Handbook for Data Driven Design](http://tinyurl.com/ybevhqo6), Sage.

**Munzner, T.** (2015) Chapter 11: _Manipulate View_, pp.242-262 in [Visualization Analysis and Design](http://tinyurl.com/ycqp5cf2), CRC Press

**Munzner, T.** (2015) Chapter 14: _Embed: Focus+Context_, pp.322-338 in [Visualization Analysis and Design](http://tinyurl.com/ycqp5cf2), CRC Press

**Satyanarayan, A., Moritz, D., Wongsuphasawat, K. and Heer, J.** (2017) [Vega-Lite: A Grammar of Interactive Graphics](https://files.osf.io/v1/resources/mqzyx/providers/osfstorage/5be5e643d354e900197998bd?action=download&version=1&direct&format=pdf). _IEEE Transactions on Visualization and Computer Graphics,_ 23(1) pp. 341-350.

**Vega-Lite** (2020) [Interactive plots with selections](https://vega.github.io/vega-lite/docs/selection.html) and [Bind a selection](https://vega.github.io/vega-lite/docs/bind.html) in _Vega-Lite Documentation_.

### References

**Shneiderman, B.** (1996) [The eyes have it: A task by data type taxonomy for information visualization](https://drum.lib.umd.edu/bitstream/handle/1903/5784/TR_96-66.pdf), _Proceedings of the IEEE Symposium on Visual Languages_, pp.336-343.

**Wood, J.** (2015) [Visualizing Personal Progress in Participatory Sports Cycling Events](http://openaccess.city.ac.uk/12351). _IEEE Computer Graphics and Applications_, 35(4), pp. 73-81.

## 7. Practical Exercises

{(task|} Please complete the following exercises before next week. {|task)}

### 1. Familiarisation with Interaction Styles

If you haven't done so already, make sure you have completed all the (pink) tasks in the lecture notes above, that help you to become familiar with the different ways you can interact with a chart and the reasons for choosing each of them.

### 2. Direct and Indirect Interaction

Consider direct (interacting with marks) and indirect (interacting via buttons, sliders, drop-down lists etc.) interaction and list the advantages and disadvantages of each by amending / adding to the two tables below. After initially filling the tables, discuss with a neighbour in the lab session or via Slack, adding any additional advantages/disadvantages that arise from the discussion.

#### Direct Interaction

| Advantages                         | Disadvantages                                |
| :--------------------------------- | :------------------------------------------- |
| Zooming and panning more intuitive | Difficult to select densely positioned marks |
| xxx                                | xxx                                          |
| etc.                               | etc.                                         |

#### Indirect Interaction

| Advantages                                  | Disadvantages |
| :------------------------------------------ | :------------ |
| Can select non position-encoded data ranges | xxx           |
| xxx                                         | xxx           |
| etc.                                        | etc.          |

### 3. Data Challenge: Interacting With a Larger Crime Dataset

The crime data used in the lecture notes are aggregated data for the West Midlands comprising 174 _neighbourhood policing units_ (NPUs). The unaggregated data are available at http://gicentre.github.io/data/westMidlands/westMidsCrimesShort.tsv

The data, in tabular form are summarised below:

| id  | month   | crimeType             | reportedCrimes | zScore | runs | gridX | gridY | NPU             |
| --- | ------- | --------------------- | -------------- | ------ | ---- | ----- | ----- | --------------- |
| 1   | 2011-01 | Anti-social behaviour | 100            | 1.3    | 1    | 16    | 5     | Birmingham East |
| 1   | 2011-02 | Anti-social behaviour | 95             | 1.1    | 2    | 16    | 5     | Birmingham East |
| 1   | 2011-03 | Anti-social behaviour | 114            | 1.8    | 3    | 16    | 5     | Birmingham East |
| :   | :       | :                     | :              | :      | :    | :     | :     | :               |
| 174 | 2016-10 | Vehicle crime         | 9              | 0.2    | 4    | 7     | 2     | Wolverhampton   |
| 174 | 2016-11 | Vehicle crime         | 7              | -0.3   | -1   | 7     | 2     | Wolverhampton   |
| 174 | 2016-12 | Vehicle crime         | 9              | 0.2    | 1    | 7     | 2     | Wolverhampton   |

where `month`, `crimeType` and `reportedCrimes` are as the examples in the lecture notes; `zScore` represents how much above or below average (measured in standard deviations) any one crime figure is; `runs` is the number of consecutive months the number of reported crimes is either above (positive) or below (negative) average; `gridX` and `gridY` are the coordinates of the NPU in a gridded map view of the West Midlands.

Imagine you have to create some interactive data visualizations for the West Midlands Police to support crime analysis of these data. Using any of the interaction approaches covered in this session, create a litvis document with some possible visualizations.

To help guide the use of interaction in your design, you may wish to link to Shneiderman's [TDIA narrative schema](https://staff.city.ac.uk/~jwo/datavis2020/narrative-schemas/tdia.yml) using this [TDIA litvis template](https://staff.city.ac.uk/~jwo/datavis2020/session06/tdiaExample.md) (which is also included in the .zip file you downloaded in Session 1) as a starting point.

_Check your progress._

- [ ] I can create a litvis document using Shneiderman's TDIA narrative schema to help guide interaction design.
- [ ] I can create an interactive visualization specification in a litvis document that contains tooltips displaying details of the encoded data.
- [ ] I can specify interaction _selections_ with litvis both directly with marks and indirectly via GUI input components.
- [ ] I can specify interaction _conditional encoding_ in a litvis visualization.
- [ ] I can specify interaction _selection filtering_ in a litvis visualization.
- [ ] I can specify interaction _scale binding_ in a litvis visualization to enable panning and zooming.
