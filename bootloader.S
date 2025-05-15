.syntax unified
.cpu cortex-m4
.thumb

.global bootload

.section .rodata
image:            .incbin "kernel.bin"
end_of_image:
str_boot_start:   .asciz "bootloader started"
str_boot_end:     .asciz "bootloader ended"
str_boot_indicate: .asciz "#"

.section .text
bootload:
    ldr r0, =str_boot_start
    bl dbgput_line

    ldr r1, =image         // Початок образу
    ldr r2, =end_of_image  // Кінець образу
    ldr r3, =_ram_start    // Куди копіювати

    sub r4, r2, r1         // r4 = розмір у байтах
    lsr r4, r4, #1         // r4 = кількість півслів (16 біт)

loop:
    ldrh r5, [r1]          // зчитуємо 16 біт
    add  r1, r1, #2        // інкремент вручну

    strh r5, [r3]          // записуємо 16 біт
    add  r3, r3, #2        // інкремент вручну

    subs r4, r4, #1
    bne loop

    // Якщо розмір непарний — копіюємо останній байт
    ldr r4, =end_of_image
    sub r4, r4, r1         // залишок байтів після основного копіювання
    tst r4, #1
    beq skip_last_byte

    ldrb r5, [r1]
    strb r5, [r3]

skip_last_byte:

    bl newline
    ldr r0, =str_boot_end
    bl dbgput_line

    // Перехід на старт ядра
    ldr r0, =_ram_start
    add r0, #4             // reset handler address
    orr r0, #1             // Thumb біт
    bx r0

bootload_end:
    b bootload_end

