.bss
stack:
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------
.text
.align 4
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------
.set BASE_ADDRESS, 0xFFFF0100
.set GOAL_X_COORD, 73
.set GOAL_Z_COORD, -19

.set SYSCALL_SET_ENGINE_AND_STEERING 10
.set SYSCALL_SET_HANDBREAK 11
.set SYSCALL_GET_POSITION 15
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------
Syscall_set_engine_and_steering:
    # a0 -> movement direction (-1 = back; 0 = stop; 1 = forward)
    # a1 -> movement angle (negative values = turn left; positive values = turn right)
    la t0, BASE_ADDRESS
    sb a0, 0x21(t0)
    sb a1, 0x20(t0)
    ret

Syscall_set_handbreak:
    # a0 -> handbreak control (1 = enable; 0 = disable)
    la t0, BASE_ADDRESS
    sb a0, 0x22(t0)
    ret

Syscall_get_position:
    # a0 -> x coord.
    # a2 -> z coord.
    la t0, BASE_ADDRESS
    li t1, 1
    sb t1, (t0)
    lw a0, 0x10(t0)
    lw a2, 0x18(t0)
    ret

int_handler:
  la t0, SYSCALL_SET_ENGINE_AND_STEERING
  beq a7, t0, Syscall_set_engine_and_steering

  la t0, SYSCALL_SET_HANDBREAK
  beq a7, t0, Syscall_set_handbreak
  
  la t0, SYSCALL_GET_POSITION
  beq a7, t0, Syscall_get_position
  
  csrr t0, mepc  # carrega endereço de retorno (endereço da instrução que invocou a syscall)  
  addi t0, t0, 4 # soma 4 no endereço de retorno (para retornar após a ecall) 
  csrw mepc, t0  # armazena endereço de retorno de volta no mepc
  mret           # recupera o restante do contexto (pc <- mepc)
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------
getXAndZCoords:
    la a7, SYSCALL_GET_POSITION
    ecall
    ret
moveForward:
    li a0, 1
    li a1, 0
    la a7, SYSCALL_SET_ENGINE_AND_STEERING
    ecall
    ret
turnLeft:
    li a0, 1
    li a1, -15
    la a7, SYSCALL_SET_ENGINE_AND_STEERING
    ecall
    ret
turnRight:
    li a0, 1
    li a1, 15
    la a7, SYSCALL_SET_ENGINE_AND_STEERING
    ecall
    ret
stop:
    li a0, 0
    li a1, 0
    la a7, SYSCALL_SET_ENGINE_AND_STEERING
    ecall
    ret
enableHandBreak:
    li a0, 1
    la a7, SYSCALL_SET_HANDBREAK
    ecall
    ret
//----------------------------------------------------------------------------------------
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
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------
.globl _start
_start:
    # carregando o endereço da rotina que tratará as interrupções
    # (e syscalls) no registrador MTVEC para configurar o vetor de interrupções
    la t0, int_handler  
    csrw mtvec, t0

    # changing privilege to User/Application
    # (updating mstatus.MPP field - bits 11 and 12 - with value 00)
    csrr t1, mstatus
    li t2, ~0x1800
    and t1, t1, t2
    csrw mstatus, t1 
    # Ajusta Pilha
    li sp, 0x07FFFFFC
    la t0, stack
    csrw mscratch, t0
    # calling user_main function
    # (loading the user software entry point into mepc)
    la t0, user_main  
    csrw mepc, t0
    mret
    jal user_main

.globl logica_controle
logica_controle:
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

    jal moveForward

    1:
    # getting actual car coord.
    jal getXAndZCoords
    mv s1, a0
    mv s2, a2    

    # waiting for get new car coord.
    li a0, 1000
    jal sleep

    # getting next car coord.
    jal getXAndZCoords
    mv s3, a0
    mv s4, a2

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

