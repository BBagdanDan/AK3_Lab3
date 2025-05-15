.syntax unified
.cpu cortex-m4
.thumb

#define A #7
#define B #5
#define C #3

// Global memory locations.
.global vtable_kernel
.global __kernel_reset__

.type vtable_kernel, %object
.type __kernel_reset__, %function

.section .interrupt_vector
vtable_kernel:
    .word __stack_start
    .word __kernel_reset__+1
    .size vtable_kernel, .-vtable_kernel

.section .rodata
    data: .asciz "kernel started!\n"
    final: .asciz "Value in r3: "

.section .text
__kernel_reset__:
    ldr r0, =data
    bl dbgput_line      // Вивести "kernel started!\n"

    push {lr}          // Зберігаємо адресу повернення

    ldr r0, =5      // a = 5
    ldr r1, =2      // b = 2
    ldr r2, =3      // c = 3

    sub r3, r0, r1  // r3 = a - b
    mov r4, #3
    mul r3, r3, r4  // (a - b) * 3

    mov r5, #1
    lsl r5, r5, r2  // 2^c

    add r3, r3, r5  // result = (a - b) * 3 + 2^c
    
    pop {lr}		// повернення

    // Вивести "Value in r3: ":
    ldr r0, =final
    bl dbgput
    // Вивести результат:
    mov r0, r3
    bl dbgput_num

end:
    b end
