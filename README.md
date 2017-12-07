# consolidation-network
model of house upgrade decision witin a social network in NetLogo

extensions [ csv ]

globals[num-nodes]
patches-own[ state total A-state B-state C-state D-state]
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

let matrix  (csv:from-file "/Users/victorpena/doctorado/2016/october/netlogo network/experiments/block102.csv" ",")

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
  set num-nodes count nodes
  repeat num-nodes * number-neighbors
  [
    ask one-of nodes [create-edge-with one-of other nodes]
  ]

  ask nodes [ ask in-link-neighbors [ set thickness 0.28 ] ]
  ask edges  [ set color yellow ]

end

to set-state
  ask nodes [
    set state-node state
  ]
end

to go

  if ;count nodes with [upgraded?] = 0
  ;or
  ticks = time-steps
  [stop]

;  ask patches[
;    if D-state = max_number_D
;    [stop]
;  ]

  ask nodes
  [
    set upgrade-check-timer upgrade-check-timer + 1
    if upgrade-check-timer >= upgrade-check-frequency
    [set upgrade-check-timer 0]
  ]

;  ask nodes
 ; [
  ;  if upgraded?
   ; [
      ;  set state state + 1
;    ]

 ; ]

  spread-upgrade
  do-upgrade-check

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
    [ask link-neighbors with [not delayed?]
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
