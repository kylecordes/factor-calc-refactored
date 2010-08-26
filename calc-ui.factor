! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors colors.constants combinators.smart kernel fry
math math.parser models namespaces sequences ui ui.gadgets
ui.gadgets.borders ui.gadgets.buttons ui.gadgets.labels
ui.gadgets.tracks ui.pens.solid ;

FROM: models => change-model ;

IN: calc-ui

TUPLE: calculator < model x y op valid ;

: <calculator> ( -- model )
    "0" calculator new-model 0 >>x ;

: reset ( model -- )
    0 >>x f >>y f >>op f >>valid "0" swap set-model ;

: display ( n -- str )
    >float number>string dup ".0" tail? [
        dup length 2 - head
    ] when ;

: set-x ( model -- model )
    dup value>> string>number >>x ;

: set-y ( model -- model )
    dup value>> string>number >>y ;

: set-op ( model quot: ( x y -- z ) -- )
    >>op set-x f >>y f >>valid drop ;

: (solve) ( model -- )
    dup [ x>> ] [ y>> ] [ op>> ] tri call( x y -- z )
    [ >>x ] keep display swap set-model ;

: solve ( model -- )
    dup op>> [ dup y>> [ set-y ] unless (solve) ] [ drop ] if ;

: negate ( model -- )
    dup valid>> [
        dup value>> "-" head?
        [ [ 1 tail ] change-model ]
        [ [ "-" prepend ] change-model ] if
    ] [ drop ] if ;

: decimal ( model -- )
    dup valid>>
    [ [ dup "." subseq? [ "." append ] unless ] change-model ]
    [ t >>valid "0." swap set-model ] if ;

: digit ( n model -- )
    dup valid>>
    [ swap [ append ] curry change-model ]
    [ t >>valid set-model ] if ;


: [C] ( calc -- button )
    "C" swap '[ drop _ reset ] <border-button> ;

: [±] ( calc -- button )
    "±" swap '[ drop _ negate ] <border-button> ;

: [+] ( calc -- button )
    "+" swap '[ drop _ [ + ] set-op ] <border-button> ;

: [-] ( calc -- button )
    "-" swap '[ drop _ [ - ] set-op ] <border-button> ;

: [×] ( calc -- button )
    "×" swap '[ drop _ [ * ] set-op ] <border-button> ;

: [÷] ( calc -- button )
    "÷" swap '[ drop _ [ / ] set-op ] <border-button> ;

: [=] ( calc -- button )
    "=" swap '[ drop _ solve ] <border-button> ;

: [.] ( calc -- button )
    "." swap '[ drop _ decimal ] <border-button> ;

: [#] ( calc n -- button )
    dup rot '[ drop _ _ digit ] <border-button> ;

: [_] ( -- label )
    "" <label> ;

: <display> ( calc -- label )
    <label-control> { 5 5 } <border>
        { 1 1/2 } >>align
        COLOR: gray <solid> >>boundary ;

: <col> ( -- track )
    vertical <track> 1 >>fill { 5 5 } >>gap ;

: <row> ( quot -- track )
    horizontal <track> 1 >>fill { 5 5 } >>gap
    swap output>array [ 1 track-add ] each ; inline

SYMBOL: calc

: calc-ui ( -- )
    <calculator> calc set
    <col> [
        calc get <display>
        [ calc get     [C] calc get     [±] calc get     [÷] calc get  [×] ] <row>
        [ calc get "7" [#] calc get "8" [#] calc get "9" [#] calc get  [-] ] <row>
        [ calc get "4" [#] calc get "5" [#] calc get "6" [#] calc get  [+] ] <row>
        [ calc get "1" [#] calc get "2" [#] calc get "3" [#] calc get  [=] ] <row>
        [ calc get "0" [#] calc get     [.]              [_]           [_] ] <row>
    ] output>array [ 1 track-add ] each
    { 10 10 } <border> "Calculator" open-window ;

MAIN: calc-ui

