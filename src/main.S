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
  ldr r1, =display_frame


@ infinite catch loop
inf_loop:
  bl display_image
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
  ldr r0, =ADR_SYST_RVR
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
.size set_priorities, .-set_priorities


.global SysTick_Handler
.type SysTick_Handler, %function
SysTick_Handler:
  push {lr}
  add r7, 1
  pop {lr}
  bx lr
.size SysTick_Handler, .-SysTick_Handler


.global GPIOTE_IRQHandler
.type GPIOTE_IRQHandler, %function
GPIOTE_IRQHandler:
  push {lr}
  // Read and clear both event registers
  ldr r0, = GPIOTE_EVENTS_IN0
  ldr r1, [r0]
  mov r2, #0
  str r2, [r0]
  ldr r0, =GPIOTE_EVENTS_IN0 + 4
  ldr r3, [r0]
  str r2, [r0]
  // Call button handler if button was pressed
call_a:
  cmp r1, #1
  bne call_b
  bl button_a
call_b:
  cmp r3, #1
  bne end_GPIOTE_IRQ
  bl button_b
end_GPIOTE_IRQ:
  pop {lr}
  bx lr
.size GPIOTE_IRQHandler, .-GPIOTE_IRQHandler


.global button_a
.type button_a, %function
button_a:
  push {lr}
  @ mov r0, 0
  @ ldr r1, =display_frame
  @ bl display_row
  pop {lr}
  bx lr
.size button_a, .-button_a


.global button_b
.type button_b, %function
button_b:
  push {lr}
  @ mov r0, 1
  @ ldr r1, =display_frame
  @ bl display_row
  pop {lr}
  bx lr
.size button_b, .-button_b


.global display_image
.type display_image, %function
// Displays an image
// --parameters--
// R1: Location of start frame
// --return--
//None
display_image:
  push {r0, r1, r2, lr}
  mov r0, #0
display_image_loop:
  cmp r0, #5
  beq display_image_end
  bl display_row
  add r0, #1
  b display_image_loop
display_image_end:
  pop {r0, r1, r2, lr}
  bx lr
.size display_image, .-display_image


.global display_row
.type display_row, %function
// Displayes a given row of a frame
// --parameters
// R0: The row number to display (0-4)
// R1: The location of the frame
// --retruen--
// None
display_row:
  push {r0, r1, r2, r3, lr}
  // Regoranise registers
  mov r2, r0
  mov r3, #1
  lsl r3, r2
  lsl r2, #2
  ldr r0, [r1, r2]
  // Initalise the LEDs
  push {r0, r1, r2, r3, lr}
  bl init_leds
  pop {r0, r1, r2, r3, lr}
  // Write to the columns
  push {r0, r1, r2, r3, lr}
  bl write_column_pins_natural
  pop {r0, r1, r2, r3, lr}
  // Write to the rows
  mov r0, r3
  push {r0, r1, r2, r3, lr}
  bl write_row_pins
  pop {r0, r1, r2, r3, lr}
  //End
  pop {r0, r1, r2, r3, lr}
  bx lr
.size display_row, .-display_row


.global short_delay
.type short_delay, %function
// Pauses the program breifley
short_delay:
  push {r0, lr}
  ldr r0, =0x2
delay_sub:
  subs r0, 1
  bmi delay_end
  b delay_sub
delay_end:
  pop {r0, lr}
  bx lr
.size short_delay, .-short_delay


.data
display_frame:
.word 0b01010
.word 0b10101
.word 0b01010
.word 0b10101
.word 0b01010