;each node repetition size increases

extensions [ csv nw ]

globals[num-nodes]
patches-own[ state total A-state B-state C-state D-state ]
turtles-own
[
  state-node
  upgraded?            ;; if true, the node is already upgraded and is influencing others
  delayed?             ;; if true, the node cannot upgrade
  upgrade-check-timer  ;; number of ticks since the last upgrade
  ]
breed [nodes node]
undirected-link-breed [edges edge]

to setup
ca

resize-world (block-size * 0) (1) (block-size * 0)  (block-size - 1)

let matrix  (csv:from-file "/Users/victorpena/doctorado/2016/october/netlogo network/experiments/block2b02.csv" ",")

ask patches
[
  let row max-pycor - pycor
  let column pxcor - min-pxcor
  set state item column item row matrix
]

ask patches
  [
    if state = 0 [set state 0]
    if state = 1 [set state 1]
    if state = 2 [set state 2]
    if state = 3 [set state 3]
    if state = 4 [set state 4]
    set pcolor brown + state
  ]

ask patches [if state = 0 [set pcolor black]]

ask patches
  [
    set A-state count patches with [state = 1]
    set B-state count patches with [state = 2]
    set C-state count patches with [state = 3]
    set D-state count patches with [state = 4]
    show count patches
  ]


  ;;;;;22DEC16;;;;;
  let zero count patches with [state > 1]
  if zero < 1
    [ask one-of patches with [state > 0] [set state 2]]
;;;;;;;;

set-default-shape nodes "circle"

ask patches with [not any? nodes-here and state > 0] [
      sprout-nodes 1 [
        set color yellow
        set size 0.2
      ]
    ]

connect-nodes
set-state
ask nodes [become-susceptible]

;;;;;;;;;;;;;;;;;;

ask nodes [set upgrade-check-timer random upgrade-check-frequency]

ask nodes with [state-node > 1]
[become-upgraded ]

  reset-ticks
  display
end

to connect-nodes
 ; set num-nodes count nodes
 ; repeat num-nodes * number-neighbors
 ; [
 ;   ask one-of nodes [create-edge-with one-of other nodes]
 ; ]

 ; ask nodes [ ask in-link-neighbors [ set thickness 0.28 ] ]
 ; ask edges  [ set color yellow ]


;;;;;;
;  let pairs [] ;; pairs will hold a pairs of turtles to be linked
;  while [ pairs = [] ] [ ;; we might mess up creating these pairs (by making self loops), so we might need to try a couple of times
;    let half-pairs reduce sentence [ n-values (number-neighbors + 1) [ self ] ] of turtles ;; create a big list where each turtle appears once for each friend it wants to have
;    set pairs (map list half-pairs shuffle half-pairs) ;; pair off the items of half-pairs with a randomized version of half-pairs, so we end up with a list like: [[ turtle 0 turtle 5 ] [ turtle 0 turtle 376 ] ... [ turtle 1 turtle 18 ]]
;    ;; make sure that no turtle is paired with itself
;    if not empty? filter [ first ? = last ? ] pairs [
;      set pairs []
;    ]
;]
;  ;; now that we have pairs that we know work, create the links

;  foreach pairs [
;    ask first ? [
;      create-link-with last ?
;    ]
;  ]

;;;;;;;;;

  ;create-turtles 100 [setxy random-xcor random-ycor]
  let target-degree number-neighbors
  while [ min [ count my-links ] of turtles < target-degree ]
  [ ask links [die]
    makeNW-Lattice target-degree
  ]

end

to makeNW-Lattice [DD]
  ask turtles
  [ let needed DD - count [my-links] of self
    if needed > 0
    [ let candidates other turtles with [ count my-links < DD ]
      create-links-with n-of min (list needed count candidates) candidates
    ]
  ]
end

to set-state
  ask nodes [
    set state-node state
  ]
end

to go

  if
  ticks = time-steps
  [stop]

  if count patches with [state = 4] = max_number_D
    [stop]


  ask nodes
  [
    set upgrade-check-timer upgrade-check-timer + 1
    if upgrade-check-timer >= upgrade-check-frequency
    [set upgrade-check-timer 0]
  ]

  spread-upgrade
  do-upgrade-check

;;; export graph 16DEC16
nw:set-context nodes links
 nw:save-graphml "b2b_119_3.graphml"

  tick
end

to become-upgraded
  set upgraded? true
  set delayed? false
  set color red
end

to become-susceptible
  set upgraded? false
  set delayed? false
  set color green
end

to become-delayed
  set upgraded? false
  set delayed? true
  set color gray
  ask my-links [set color gray - 2]
end

to spread-upgrade
  ask nodes with [upgraded?]
    [ask one-of link-neighbors with [not delayed?] ;;;; one-of 23OCT bien!!!
      [if random-float 100 < upgrade-spread-chance
          [ become-upgraded
            set state state + 1
          ]
      ]
    ]
  ask patches
    [
    ;if state = 0 [set state 0]
    if state = 1 [set state 1]
    if state = 2 [set state 2]
    if state = 3 [set state 3]
    if state = 4 [set state 4]
    if state > 4 [set state 4]
    set pcolor brown + state
    ]

  ask patches
    [
    set A-state count patches with [state = 1]
    set B-state count patches with [state = 2]
    set C-state count patches with [state = 3]
    set D-state count patches with [state = 4]
    show count patches
     ifelse show-state?
     [set plabel state]
     [set plabel ""]
    ]

  recolor-patch

end

to do-upgrade-check
  ask nodes with [upgraded?  and upgrade-check-timer = 0]
  [
    if random 100 < recovery-chance
    [
      ifelse random 100 < gain-resistance-chance
      [become-delayed]
      [become-susceptible]
    ]
  ]

end

to recolor-patch
  ask patches with [state < 5 ]
  [
  ifelse state = min [state] of patches
  [set pcolor green]
  [set pcolor brown + state]
  ]

end
@#$#@#$#@
GRAPHICS-WINDOW
292
10
537
521
-1
-1
32.0
1
10
1
1
1
0
0
0
1
0
1
0
14
0
0
1
ticks
30.0

SLIDER
13
138
185
171
block-size
block-size
0
50
15
1
1
NIL
HORIZONTAL

BUTTON
16
25
139
58
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
482
29
576
78
NIL
count nodes
0
1
12

MONITOR
482
91
576
140
NIL
count edges
0
1
12

SLIDER
15
370
224
403
upgrade-check-frequency
upgrade-check-frequency
1
10
1
1
1
NIL
HORIZONTAL

SLIDER
15
413
220
446
upgrade-spread-chance
upgrade-spread-chance
0
100
75
1
1
NIL
HORIZONTAL

SLIDER
16
456
188
489
recovery-chance
recovery-chance
0
100
24
1
1
NIL
HORIZONTAL

SLIDER
16
500
217
533
gain-resistance-chance
gain-resistance-chance
0
100
1
1
1
NIL
HORIZONTAL

BUTTON
16
80
79
113
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
591
154
648
203
NIL
ticks
0
1
12

PLOT
894
24
1233
195
Contagion rates
time-steps
% of nodes
0.0
15.0
0.0
80.0
true
true
"" ""
PENS
"susceptible" 1.0 0 -15040220 true "" "plot (count nodes with [not upgraded? and not delayed?])/(count nodes) * 100"
"upgraded" 1.0 0 -2674135 true "" "plot (count nodes with [upgraded?]) / (count nodes) * 100"
"delayed" 1.0 0 -7500403 true "" "plot (count nodes with [delayed?])/(count nodes) * 100"

SLIDER
15
193
187
226
number-neighbors
number-neighbors
1
50
3
1
1
NIL
HORIZONTAL

MONITOR
783
23
840
72
green
count nodes with [not upgraded? and not delayed?]
0
1
12

MONITOR
783
83
840
132
red
count nodes with [upgraded?]
0
1
12

MONITOR
783
143
840
192
gray
count nodes with [ delayed?]
0
1
12

SLIDER
14
236
186
269
time-steps
time-steps
1
100
100
1
1
NIL
HORIZONTAL

BUTTON
107
84
188
117
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
957
296
1230
575
Trajectories
time-steps
number of houses
0.0
15.0
0.0
30.0
true
true
"" ""
PENS
"A" 1.0 0 -2674135 true "" "plot count patches with [state = 1]"
"B" 1.0 0 -13345367 true "" "plot count patches with [state = 2]"
"C" 1.0 0 -13210332 true "" "plot count patches with [state = 3]"
"D" 1.0 0 -14737633 true "" "plot count patches with [state = 4]"

MONITOR
958
228
1015
277
A
count patches with [state = 1]
0
1
12

MONITOR
1032
229
1089
278
B
count patches with [state = 2]
0
1
12

MONITOR
1105
228
1162
277
C
count patches with [state = 3]
0
1
12

MONITOR
1181
229
1238
278
D
count patches with [state = 4]
0
1
12

SLIDER
16
279
188
312
max_number_D
max_number_D
0
50
20
1
1
NIL
HORIZONTAL

SWITCH
20
330
152
363
show-state?
show-state?
0
1
-1000

MONITOR
480
153
576
202
active edges
count edges with [color = yellow]
0
1
12

PLOT
650
226
942
576
Nodes to houses
Proportion (C+D)
Upgraded nodes
0.0
0.1
0.0
10.0
true
true
"" ""
PENS
"Nodes" 1.0 0 -2674135 true "" "plotxy (((count patches with [state = 3]) + (count patches with [state = 4])) / (block-size * 2))\n (count nodes with [upgraded?])"

MONITOR
667
155
744
204
Up nodes
count nodes with [upgraded?]
0
1
12

MONITOR
672
93
734
142
Density
(((count patches with [state = 3]) + (count patches with [state = 4])) / (block-size * 2))
2
1
12

PLOT
414
225
635
418
Proportions
Proportion D
Proportion (B+C)
0.0
1.0
0.0
1.0
true
false
"" ""
PENS
"c" 1.0 0 -16777216 true "" "plotxy ((count patches with [state = 4]) / (block-size * 2)) ((count patches with [state = 3] + count patches with [state = 2]) / (block-size * 2))"

@#$#@#$#@
## WHAT IS IT?

A model of house upgrade (consolidation) diffusion within a network that represent interactions between householders

## HOW IT WORKS

SIRS model of epidemic diffusion is used to replicate social influence across the process of consolidation within the space of a given housing block that is represented by a grid space. Algorithm is based on Stonedahl and Wilenski Netlogo Virus on a Network model (2008).

## HOW TO USE IT

A csv file that contains a matrix with values from 0 to 3 should be loaded, they represents 4 state conditions and matrix correspond to initial state configuration of grid space. Spread Chance, Recovery Chance and resistance Chance sliders are the probability of upgrade, probability of continue upgrading and probability of keeping the same state as taken from empirical observations at house scale.

## THINGS TO NOTICE

Once initial setting are defined model runs and show grid configuration change and trajectories of change in state.

## THINGS TO TRY

Composition matrix could be imported, representon any given condition that is going to be tested or replicaqted.
Probabilities (sliders) could be changed in order to investigate change in configuration and trajectories.

## EXTENDING THE MODEL

Model is intended to be generalizable to the whole range of conditions observed within informal development. However, it could be improved by adding an component that considers family growing within each grid, reflecting demographic patterns or housing needs that are credited to be influencing decision to upgrade the house.

## NETLOGO FEATURES

Data input imports initial house state composition and configuration within the block from cvs files.

## RELATED MODELS

Model 69 by Victor Peña-Guillen (2017) located into Netlogo User Community http://ccl.northwestern.edu/netlogo/models/community/block69 is a related model that use cellular automata and a simple upgrading rule to replicate and investigate dynamic nature of house consolidation.
## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
