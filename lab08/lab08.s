.text
//----------------------------------------------------------------
.set BASE_ADDRESS, 0xFFFF0100
.set GOAL_X_COORD, 73
.set GOAL_Z_COORD, -19
//----------------------------------------------------------------
startGPS:
    li t0, 1
    sb t0, (s0)
    ret

getXCoord:
    lw a0, 0x10(s0)
    ret

getZCoord:
    lw a0, 0x18(s0)
    ret

moveForward:
    li t0, 1
    sb t0, 0x21(s0)
    ret

turnLeft:
    li t0, -15
    sb t0, 0x20(s0)
    ret

turnRight:
    li t0, 15
    sb t0, 0x20(s0)
    ret

stop:
    li t0, 0
    sb t0, 0x21(s0)
    ret

enableHandBreak:
    li t0, 1
    sb t0, 0x22(s0)
    ret
//----------------------------------------------------------------
rotateGoalVector90Degrees:
    # coord. of goal vector before rotation: (s7, s8)
    # coord. of goal vector after rotation:  (s8, -s7)
    mv t0, s7
    mv s7, s8
    li t1, -1
    mul s8, t0, t1
    ret

getInternalProduct:
    # coord. of movement vector: (s5, s6)
    # coord. of movement vector: (s7, s8)
    # result of internal product: s5*s7 + s6*s8
    li a0, 0
    mul t0, s5, s7
    mul t1, s6, s8
    add a0, t0, t1
    ret
//----------------------------------------------------------------
time:
    # allocate space in stack and saving new sp value in a0
    addi sp, sp, -16
    mv a0, sp
    # get system time and saving it in stack
    mv a1, zero
    li a7, 169
    ecall
    # getting system time from stack 
    lw t0, 0(sp)
    lw t1, 8(sp)
    addi sp, sp, 16
    # convert system time to milisseconds
    li t2, 1000
    mul t0, t0, t2
    div t1, t1, t2
    add a0, t1, t0
    ret

sleep:
    # store ra in stack
    addi sp, sp, -4
    sw ra, 0(sp)
    # store a0 (time to sleep in milisseconds) in stack
    addi sp, sp, -4
    sw a0, 0(sp)
    # get system time and saving it in t3
    jal time
    mv t3, a0
    1:
        # case system time in less than system time + time to sleep: keep in loop
        # case not, break loop jumping to 1f
        jal time
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
//----------------------------------------------------------------
exit:
    li a0, 0
    li a7, 93
    ecall
//----------------------------------------------------------------
.globl _start
_start:
    /* in this program, we will consider 2 vectors:
     - movement vector (from the previous to the current position of the car)
     - goal vector (from the car's current position to its goal point)
     about registers, we will use:
     - s0 -> BASE_ADDRESS
     - s1 -> x coord. of actual before sleep
     - s2 -> z coord. of actual before sleep
     - s3 -> x coord. of position after sleep
     - s4 -> z coord. of actual after sleep
     - s5 -> x coord. of movement vector
     - s6 -> z coord. of movement vector
     - s7 -> x coord. of goal vector
     - s8 -> y coord. of goal vector */

    li s0, BASE_ADDRESS
    
    jal startGPS
    jal moveForward

    1:
    # getting actual car coord.
    jal getXCoord
    mv s1, a0
    jal getZCoord
    mv s2, a0    

    # waiting for get new car coord.
    li a0, 1000
    jal sleep
    
    # getting next car coord.
    jal getXCoord
    mv s3, a0
    jal getZCoord
    mv s4, a0

    # getting movement vector
    mv s5, s3
    sub s5, s5, s1
    mv s6, s4
    sub s6, s6, s2

    # get goal vector
    li s7, GOAL_X_COORD
    li s8, GOAL_Z_COORD
    sub s7, s7, s3
    sub s8, s8, s4

    # rotate goal vector
    jal rotateGoalVector90Degrees

    # calculating <goal vector, movement vector>
    jal getInternalProduct

    # changing wheel direction
    beqz a0, 1f
    bgt a0, zero, turnLeft
    blt a0, zero, turnRight

    # keep in loop if wheel direction is different than goal direction
    jal 1b

    1:
    # finishing program
    jal stop
    jal enableHandBreak 
    jal exit