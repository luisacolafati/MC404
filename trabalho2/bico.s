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
    /* a0 -> array representing image
       a1 -> filter vector */
    mv s0, a0
    # save zero in stack
    addi sp, sp, -1
    sb zero, 0(sp)
    # set basic pixels colors
    li t0, 0
    li t1, 255
    2:
        # case already filter 255 pixels, restore pixels saved in stack
        li t6, 0
        beq t0, t1, 2f
        # case is reading first pixel (border pixel)
        beqz t0, 3f
        # case is not reading first pixel
        li s1, 0
        ## apply filter vector in pixel
        lb s2, 0(a1)
        lbu s4, -1(s0)
        mul t6, s2, s4
        add s1, s1, t6

        lb s2, 1(a1)
        lbu s4, 0(s0)
        mul t6, s2, s4
        add s1, s1, t6

        lb s2, 2(a1)
        lbu s4, 1(s0)
        mul t6, s2, s4
        add s1, s1, t6
        # case pixel value < 0, set it to 0
        blt s1, zero, setBlackPixel
        # case pixel value > 255, set it to 255
        bgt s1, t1, setWhitePixel
        j 3f
        setWhitePixel:
            li s1, 255
            j 3f
        setBlackPixel:
            li s1, 0
        3:
        # store pixel filtered in stack
        addi sp, sp, -1
        sb s1, 0(sp)
        # filter next image pixel
        addi s0, s0, 1
        addi t0, t0, 1
        j 2b
    2:
    # store a border pixel (black) in stack
    addi sp, sp, -1
    sb zero, 0(sp)
    # control variables for read 255 pixels from stack
    li t1, 0
    li t2, 256
    2:
        beq t1, t2, 2f
        # read pixels from stack
        lbu t3, 0(sp)
        # save pixels in s0
        sb t3, 0(s0)
        # adjust control variables for read next pixel from stack 
        addi sp, sp, 1
        addi s0, s0, -1
        addi t1, t1, 1
        j 2b
    2:
    # restore stack and finish routine
    addi sp, sp, 1
    ret

.globl display_image
display_image:
    # allocate stack frame for call draw_line routine
    addi sp, sp, -16
    # store ra and a1 in stack frame
    sw ra, 0(sp)
    sw a1, 8(sp)
    # call draw_line
    li a1, 0
    jal draw_line
    # restore stack frame
    lw a1, 8(sp)
    lw ra, 0(sp)
    addi sp, sp, 16
    # allocate stack frame for call draw_line routine again
    addi sp, sp, -16
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    # call draw_line
    addi a0, a0, 126
    li a1, 504
    jal draw_line
    # restore stack frame
    lw a1, 8(sp)
    lw a0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 16
    # finish routine
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
    lw a0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 16
    ret

.globl atoi
atoi:
    /* a0 -> string to convert in int */
    ## a0 -> will return decimal value of string
    ## a1 -> string to convert in decimal
    ## t1 -> byte read from string
    ## t2 -> indicates signal of number: positive (t2=1) or negative (t2=-1)
    ## t3 -> auxiliar variable
    mv a1, a0 
    li a0, 0
    li t2, 1  # flag for control if number is positive (t6=1) or negative (t6=-1)
    # loading first byte
    lbu t1, 0(a1)
    # case first byte is '-' (ASCII code 45), set -1 in a6 and read next byte
    li t3, 45
    beq t1, t3, 3f
    # case first byte is '+' (ASCII code 43), keep 1 in a6 and read next byte
    li t3, 43
    beq t1, t3, 4f
    2:
        # reading a byte from string
        lbu t1, 0(a1)
        # case byte is outside range ['0'(ASCII code 48), '9'(ASCII code 57)], skip loop
        li t3, 48
        blt t1, t3, 2f
        li t3, 57
        bgt t1, t3, 2f
        # case byte is in range ['0', '9']
        addi t1, t1, -48  # get decimal value of numeric digit 
        li t3, 10
        mul a0, a0, t3    # adjust number magnitude multiplying it by 10
        add a0, a0, t1    # add decimal value of byte read in a0
        j 4f
        3:
            # case number is negative, set -1 in a6
            li t2, -1
        4:
        # read next byte 
        addi a1, a1, 1
        j 2b
    2:
    # adjust number signal multiplying by a6
    mul a0, a0, t2
    # return decimal value of string in a0
    ret

.globl itoa
itoa:
    /* a0 -> number to convert in string
       a1 -> address to save string
       a2 -> base to convert number before convert it in string
    */
    mv t0, a0
    mv t1, a1
    # saving number 9 in stack
    addi sp, sp, -1
    li t2, 9
    sb t2, 0(sp)
    2:
        rem s0, a0, a2    # s0 = a0 % a2
        div a0, a0, a2    # a0 = a0 / a2
        bgt s0, t2, 3f    # case (a0 % a2) > 9, number is in hexadecimal base
        # case number is not in hexadecial base, add '0' to it to get a number
        # in range [0, 9] representation as string
        addi s0, s0, '0'  
        j 4f
        3:
        # case number is in hexadecimal base
        ## convert hexadecimal representations of a, b, c, d, e and f in numbers in range [10, 16]
        addi s0, s0, -10
        addi s0, s0, 'a'
        4:
        # save digit in stack
        addi sp, sp, -1
        sb s0, 0(sp)
        # skip loop if a0 = 0 (no more string bytes to convert to int)
        beqz a0, 2f
        j 2b
    2:
    blt t0, zero, 3f
    # case number is positive
    ## get last character save in stack
    lb s1, 0(sp)
    addi sp, sp, 1
    ## case this character is 9, finish conversion
    beq s1, t2, 4f
    ## case not, store character and keep conversion
    sb s1, 0(t1)
    addi t1, t1, 1
    j 2b
    3:
        # case number is negative
        ## case base is not 10, skip negative representation
        li t2, 10
        bne a2, t2, 4f
        ## case base is 10, add a character '-' in string init to represent negative number
        li t2, 45    # ASCII code for character '-'
        lb t2, 0(t1)
        # point to next string byte
        addi t1, t1, 1
    4:
    # finish conversion
    sb zero, 0(t1)
    mv a0, a1
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
    /* a0 -> decimal value to get square root (y) 
       a1 -> number of algorithm iteractions
    */
    ## Calculating square root with Babylonian Method
    ## in first iteration, s1 = k = y / 2
    ## after that, s1 = (k + y / k) / 2,
    ## where s2 = (k + y / k)
    li t1, 2
    div s1, a0, t1
    # iteractions of Babylonian Method:
    li t2, 1
    2:
        # decrement number of iteractions
        sub a1, a1, t2
        # calculating estimate root
        div s2, a0, s1  # s2 = y / k
        add s2, s2, s1  # s2 = k + (y / k)
        div s1, s2, t1  # s1 = (k + y / k) / 2
        # keep in loop 
        blt zero, a1, 2b
    mv a0, s1
    ret
