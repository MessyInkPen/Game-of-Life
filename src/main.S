.syntax unified

// GPIOTE and NVIC Constants
.set GPIOTE_EVENTS_IN0, 0x40006100
.set GPIOTE_INTENSET, 0x40006304
.set GPIOTE_CONFIG0, 0x40006510
.set NVIC_ISER0, 0xE000E100

.global main
.type main, %function
// Starts up the program
//  - sets inputs
//  - sets interupts
//  - sets priorities
main:
  bl set_GPIOTE
  @ bl set_interupts
  @ bl set_priorities

@ infinite catch loop
inf_loop:
  nop
  b inf_loop

.global set_GPIOTE
.type set_GPIOTE, %function
set_GPIOTE:
  // Configure GPIOTE_CONFIG[0] for P0.14 (Button A)
  ldr r0, =GPIOTE_CONFIG0
  ldr r1, =(1 | 14 << 8 | 1 << 16)
  str r1, [r0]
  // Configure GPIOTE_CONFIG[1] for  (buttom B)
  add r0, 4
  ldr r1, =(1 | 23 << 8 | 1 << 16)
  str r1, [r0]
  // Enable interupts for GPIOTE[0] and GPIOTE[1]
  ldr r0, =GPIOTE_INTENSET
  ldr r1, =0b11
  str r1, [r0]
  //Enable GPIOTE interrupt in NVIC
  ldr r0, =NVIC_ISER0
  ldr r1, =(1 << 6)
  str r1, [r0]
  bx lr
