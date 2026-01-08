.syntax unified
.global main

cope:
  .ascii "COPE"

.type main, %function
main:
  @ load "COPE" into r1
  ldr r1, cope

  @ fill in the rest of the instructions here!


@ infinite catch loop
inf_loop:
  nop
  b inf_loop
  