    .text
	.syntax unified
	.global int2float

int2float:
   mov r1, #65536
   mov r7, #0
   cmp r0, #0
   blt inverse
   bge else
inverse:
   mvn r0, r0
   add r0, r0, #1
   mov r7, #1
else:

   mul r0, r0, r1
   ldr r1,=0x40000000
   mov r3, #1
cal_expo:
   and r2, r1, r0
   cmp r2, r1
   mov r1, r1, lsr #1
   add r3, r3, #1
   bne cal_expo

mov r1, #16
sub r1, r1, r3
mov r5, #127

comparation_avec_7:
   mov r6, #7
   cmp r1, r6
   blt moins
   bgt grand
   beq egale

moins:
   add r5, r5, r1
   sub r1, r6, r1
   mov r0, r0, lsl r1
   bl resultat

grand:
   add r5, r5, r1
   sub r1, r1, r6
   mov r0, r0, lsr r1
   bl resultat

egale:
   add r5, r5, r6
   bl resultat

resultat:
   ldr r4, =0x007fffff
   and r0, r4, r0

mov r5, r5, lsl#23
add r0, r0, r5
cmp r7, #1
beq resultat_negatif
bne end
resultat_negatif:
   sub r0, r0, #1
   mvn r0, r0
end:

swi 0x11

/***********************************************************************/
   .global addfloat
addfloat:         //r1 + r2
    ldr r8, =0x7f800000
    and r4, r1, r8
    and r5, r2, r8
    cmp r4, r5
    bcc echanger
    bhi continue
echanger:
    mov r3, r1
    mov r1, r2
    mov r2, r3
    and r4, r1, r8
    and r5, r2, r8
continue:

mov r4, r4, lsr #23
mov r5, r5, lsr #23
sub r3, r4, r5
ldr r8, =0x007fffff
and r5, r1, r8
and r6, r2, r8
ldr r8, =0x00800000
orr r5, r5, r8
orr r6, r6, r8
mov r6, r6, lsr r3

ldr r8, =0x80000000
and r0, r1, r8
cmp r0, r1
bne suite1
beq else1
suite1:
    mov r0, r5
    bl complement
    mov r5, r0
else1:

and r0, r2, r8
cmp r0, r2
bne suite2
beq else2
suite2:
    mov r0, r6
    bl complement
    mov r6, r0
else2:

add r5, r5, r6
and r0, r5, r8
cmp r0, r5
bne suite3
beq suite4
suite3:
    mov r0, r5
    bl complement
    mov r5, r0
    orr r0, #0x80000000

suite4:
    and r0, #0

complement:
    mvn r0, r0
    add r0, r0, #1
    mov pc, lr

mov r3, #0
ldr r10, =0x80000000
calcul_decalage:
    cmp r10, r5
    bcc suite5
    bhi end5
suite5:
    add r3, r3, #1
    mov r10, r10, lsr #1
    b calcul_decalage
end5:

cmp r3, #8
bhi grand2
bcc moins2
grand2:
    sub r3, r3, #8
    mov r5, r5, lsl r3
    sub r4, r4, r3
    bl resultat2
moins2:
    rsb r3, r3, #8
    mov r5, r5, lsr r3
    add r4, r4, r3
    bl resultat2
resultat2:
mov r4, r4, lsl #23
orr r0, r0, r4
ldr r10, =0x007fffff
and r5, r5, r10
orr r0, r0, r5
mov pc, lr



