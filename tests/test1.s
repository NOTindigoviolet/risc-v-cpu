.global _start
.section .text

_start:
    addi x1, x0, 5
    addi x2, x1, 10
    sw x2, 0(x0)
halt:
    j halt