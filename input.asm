// Terminal input boundary. This is the only module that depends on scanf/getchar.
.arch armv8-a

.section .rodata
input_integer_format: .asciz "%d"

.section .bss
.balign 4
input_value: .skip 4

.section .text
.balign 4
.global input_read_integer
.type input_read_integer, %function
// Reads one signed integer. Returns it in w0, or -1 when no integer was entered.
input_read_integer:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    adrp    x0, input_integer_format
    add     x0, x0, :lo12:input_integer_format
    adrp    x1, input_value
    add     x1, x1, :lo12:input_value
    bl      scanf
    cmp     w0, #1
    b.eq    .Linput_success

    bl      input_discard_line
    mov     w0, #-1
    b       .Linput_done

.Linput_success:
    adrp    x1, input_value
    add     x1, x1, :lo12:input_value
    ldr     w0, [x1]
.Linput_done:
    ldp     x29, x30, [sp], #16
    ret

.global input_discard_line
.type input_discard_line, %function
// Consumes the rest of an invalid input line, including its newline.
input_discard_line:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
.Ldiscard_next:
    bl      getchar
    cmp     w0, #10
    b.eq    .Ldiscard_done
    cmn     w0, #1                 // EOF is -1.
    b.ne    .Ldiscard_next
.Ldiscard_done:
    ldp     x29, x30, [sp], #16
    ret
