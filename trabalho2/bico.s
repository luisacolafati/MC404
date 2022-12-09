.text
//----------------------------------------------------------------------------------------
.set SYSCALL_SET_MOTOR, 10
.set SYSCALL_SET_HANDBREAK, 11
.set SYSCALL_READ_SENSORS, 12
.set SYSCALL_READ_SENSOR_DISTANCE, 13
.set SYSCALL_GET_POSITION, 15
.set SYSCALL_GET_ROTATION, 16
.set SYSCALL_READ, 17
.set SYSCALL_WRITE, 18
.set SYSCALL_DRAW_LINE, 19
.set SYSCALL_GET_SYSTIME, 20
//----------------------------------------------------------------------------------------
.globl set_motor
set_motor:
    /* a0 -> vertical displacement = [-1, 1]
       a1 -> horizontal displacement = [-127, 127] */
    # allocate stack
    addi sp, sp, -16
    # save ra in stack
    sw ra, 0(sp)
    # do a syscall
    li a7, SYSCALL_SET_MOTOR
    ecall
    # restore ra and stack
    lw ra, 0(sp)
    addi sp, sp, 16
    ret

.globl set_handbreak
set_handbreak:
    /* a0 -> handbreak control (1 = enable, 0 = disable) */
    # allocate stack
    addi sp, sp, -16
    # save ra in stack
    sw ra, 0(sp)
    # do a syscall
    li a7, SYSCALL_SET_HANDBREAK
    ecall
    # restore ra and stack
    lw ra, 0(sp)
    addi sp, sp, 16
    ret

.globl read_camera
read_camera:
    /* a0 -> buffer to store bytes read from camera */
    # allocate stack
    addi sp, sp, -16
    # save ra in stack
    sw ra, 0(sp)
    # do a syscall
    li a7, SYSCALL_READ_SENSORS
    ecall
    # restore ra and stack
    lw ra, 0(sp)
    addi sp, sp, 16
    ret

.globl read_sensor_distance
read_sensor_distance:
    # allocate stack
    addi sp, sp, -16
    # save ra in stack
    sw ra, 0(sp)
    # do a syscall
    li a7, SYSCALL_READ_SENSOR_DISTANCE
    ecall
    # restore ra and stack
    lw ra, 0(sp)
    addi sp, sp, 16
    ret

.globl get_position
get_position:
    /* a0 -> address to store X position
       a1 -> address to store Y position
       a2 -> address to store Z position */
    # allocate stack
    addi sp, sp, -16
    # save ra in stack
    sw ra, 0(sp)
    # do a syscall
    li a7, SYSCALL_GET_POSITION
    ecall
    # restore ra and stack
    lw ra, 0(sp)
    addi sp, sp, 16
    ret

.globl get_rotation
get_rotation:
    /* a0 -> address to store X Euler Angle
       a1 -> address to store Y Euler Angle
       a2 -> address to store Z Euler Angle */
    # allocate stack
    addi sp, sp, -16
    # save ra in stack
    sw ra, 0(sp)
    # do a syscall
    li a7, SYSCALL_GET_ROTATION
    ecall
    # restore ra and stack
    lw ra, 0(sp)
    addi sp, sp, 16
    ret

.globl read
read:
    # allocate stack
    addi sp, sp, -16
    # save ra in stack
    sw ra, 0(sp)
    # do a syscall
    li a7, SYSCALL_READ
    ecall
    # restore ra and stack
    lw ra, 0(sp)
    addi sp, sp, 16
    ret

.globl write
write:
    # allocate stack
    addi sp, sp, -16
    # save ra in stack
    sw ra, 0(sp)
    # do a syscall
    li a7, SYSCALL_WRITE
    ecall
    # restore ra and stack
    lw ra, 0(sp)
    addi sp, sp, 16
    ret

.globl draw_line
draw_line:
    /* a0 -> buffer to print in Canvas */
    # allocate stack
    addi sp, sp, -16
    # save ra in stack
    sw ra, 0(sp)
    # do a syscall
    li a7, SYSCALL_DRAW_LINE
    ecall
    # restore ra and stack
    lw ra, 0(sp)
    addi sp, sp, 16
    ret

.globl get_time
get_time:
    # allocate stack
    addi sp, sp, -16
    # save ra in stack
    sw ra, 0(sp)
    # do a syscall
    li a7, SYSCALL_GET_SYSTIME
    ecall
    # restore ra and stack
    lw ra, 0(sp)
    addi sp, sp, 16
    ret
//----------------------------------------------------------------------------------------
.globl filter_1d_image
filter_1d_image:
    ret


.globl display_image
display_image:
    ret
//----------------------------------------------------------------------------------------
.globl puts
puts:
    # allocate stack
    addi sp, sp, -16
    # save ra in stack
    sw ra, 0(sp)
    # do a syscall
    mv a1, a0
    jal write
    # restore ra from stack
    lw ra, 0(sp)
    addi sp, sp, 16
    ret

.globl gets
gets:
    # allocate stack
    addi sp, sp, -16
    # save a0 and ra in stack
    sw ra, 0(sp)
    sw a0, 4(sp)
    # do a syscall
    mv a1, a0
    jal read
    # restore a0 and ra from stack
    lw ra, 0(sp)
    addi sp, sp, 16
    ret

.globl atoi
atoi:
    /* a0 -> string to convert to integer */
    li t0, 0   # string decimal value
    li t1, 10  # auxiliar value for calculate string decimal value 
    li t2, 1   # flag to identify if number is negative (t2=-1) or positive (t2=1)
    # loading first byte of string
    lbu t3, 0(a0)
    # case first byte == '-' (ASCII code 43)
    li t4, 45
    bne t3, t4, 2f
    # case number is negative
    li t2, -1
    2:
        # case number is positive
        lbu t3, 0(a0)
        # case byte is outside range ['0'(ASCII code 48), '9'(ASCII code 57)] 
        li t4, 48
        blt t3, t4, 2f
        li t4, 57
        bgt t3, t4, 2f
        # case byte is a digit in range ['0', '9']
        addi t3, t3, -48
        mul t0, t0, t1
        add t0, t0, t3
        # adjusting loop for read next byte
        addi a0, a0, 1
        j 2b
    2:
    mul t0, t0, t2
    mv a0, t0
    ret

.globl itoa
itoa:
    /* a0 -> number to convert
       a1 -> buffer to save converted number
       a2 -> base to convert number */
    li t6, 0 # control flag for register if number is negative (t6=1) or positive (t6=0)
    bnez a0, 2f
    # case a0 == 0
    li t0, 10
    sb t0, (a1)
    li t0, 48
    sb t0, 1(a1)
    ret
    2:
        li t0, 10
        bne a2, t0, 3f
        bgt a0, zero, 3f
        # case a2 == 10 && a0 < 0
        li t6, 1
        li t0, -1
        mul a0, a0, t0
        3:
        # case a2 != 10 || a0 >= 0
        rem t1, a0, a2
        li t0, 9
        bgt t1, t0, 4f
        # case a0 % a2 > 9
        addi t1, t1, -10
        addi t1, t1, 'A'
        sb t0, (a1)
        j 5f
        4:
        # case a0 % a2 <= 9
        li t0, '0'
        sb t0, (a1)
        5:
        div a0, a0, a2
        addi a1, a1, 1
        j 2b
        
    li t0, 1
    bne t6, t1, 2f
    # case a0 < 0
    addi a1, a1, 1
    li t0, '-'
    sb t0, (a1)
    2:
    # append '\0' in string
    addi a1, a1, 1
    li t0, 10
    sb t0, (a1)
    # reverse bytes from string
    lb t0, 0(a1)
    lb t1, 1(a1)
    lb t2, 2(a1)
    lb t3, 3(a1)
    # saving bytes in a0 in reverse order
    sb t3, 0(a1)
    sb t2, 1(a1)
    sb t1, 2(a1)
    sb t0, 3(a1)
    # return
    ret

.globl sleep
sleep:
    # store ra in stack
    addi sp, sp, -4
    sw ra, 0(sp)
    # store a0 (time to sleep in milisseconds) in stack
    addi sp, sp, -4
    sw a0, 0(sp)
    # get system time and saving it in t3
    jal get_time
    mv t3, a0
    1:
        # case system time in less than system time + time to sleep: keep in loop
        # case not, break loop jumping to 1f
        jal get_time
        lw a1, 0(sp)
        addi sp, sp, 4
        sub a0, a0, t3
        bge a0, a1, 1f
        addi sp, sp, -4
        sw a1, 0(sp)
        j 1b
    1:
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

.globl approx_sqrt
approx_sqrt:
    /* a0 -> y = decimal value to get square root (y) 
       a1 -> number of algorithm iteractions */
    li t0, 2
    divu t1, a0, t0
    # iteractions of Babylonian Method
    mv t5, a1 # max iteractions number
    li t6, 0  # current iretaction number
    2:
        # exit while loop after max iteractions
        bge t6, t5, 2f
        # calculating estimate root
        divu t2, s0, t1  # t2 = y / k = s0 / t1
        add t3, t1, t2   # t3 = k + y / k = t1 + t2
        divu t4, t3, t0  # t4 = (k + y / k) / 2 = t3 / t0
        addi t1, t4, 0   # saving estimate root (t4) in t1 
        # increment number of iteractions
        addi t6, t6, 1
        # keep in while loop
        jal 2b
    2:
    ret