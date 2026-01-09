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
  bl set_interupts
  bl set_priorities

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
.size set_GPIOTE, .-set_GPIOTE

.global set_interupts
.type set_interupts, %function
set_interupts:
  // Enable SYST_CSR
  ldr r4, =ADR_SYST_CSR
  ldr r2, =0
  ldr r3, [r4]
  mov r5, 0b1
  lsl r5, r5, r2
  orr r3, r3, r5
  // Set CLKSOURCE
  ldr r2, =2
  mov r5, 0b1
  lsl r5, r5, r2
  orr r3, r3, r5
  ldr r2, =1
  mov r5, 0b1
  lsl r5, r5, r2
  orr r3, r3, r5
  str r3, [r4]
  // Set SYSY_RVR: 4000000
  ldr r0, =ADR_SYST_CSR
  ldr r1, =0x3D0900
  str r1, [r0]
  bx lr
.size set_interupts, .-set_interupts

.global set_priorities
.type set_priorities, %function
set_priorities:
  // Timer interupts
  ldr r0, =0xE000ED20
  ldr r1, [r0]
  orr r1, r1, 0xE0000000
  str r1, [r0]
  // GPIOTE interupts
  ldr r0, =0xE000E404
  ldr r1, [r0]
  and r1, r1, 0xFF1FFFFF
  str r1, [r0]
  bx lr