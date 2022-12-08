.bss
.stack:
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------
.text
.align 4
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------
.set BASE_ADDRESS, 0xFFFF0100
.set STACK_POINTER_BASE_ADDRESS, 0x07FFFFFC

.set GOAL_X_COORD, 73
.set GOAL_Z_COORD, -19

.set SYSCALL_SET_MOTOR, 10
.set SYSCALL_SET_HANDBREAK, 11
.set SYSCALL_READ_SENSORS, 12
.set SYSCALL_SET_SENSOR_DISTANCE, 13
.set SYSCALL_GET_POSITION, 15
//----------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------
Syscall_set_motor:
    li t0, BASE_ADDRESS
    # validating params received (a0 and a1)
    ## case a0 is outside valid range [-1, 1]
    li t1, -1
    blt a0, t1, returnParamOutsideRangeError
    li t1, 1
    bgt a0, t1, returnParamOutsideRangeError
    ## case a1 is outside valid range [-127, 127]
    li t1, -127
    blt a1, t1, returnParamOutsideRangeError
    li t1, 127
    bgt a1, t1, returnParamOutsideRangeError
    # changing movement direction ang angle
    sb a0, 0x21(t0)
    sb a1, 0x20(t0)
    li a0, 0
    ret

returnParamOutsideRangeError:
    li a0, -1
    jal 1f

Syscall_set_handbreak:
    li t0, BASE_ADDRESS
    sb a0, 0x22(t0)
    ret

Sycall_read_sensors:
    li t0, BASE_ADDRESS
    # trigger line camera to register image
    li t1, 1
    sb t1, 0x01(t0)
    # readind each byte captured by camera in memory
    ## t2 -> memory address to load byte
    ## t3 -> memory address to store byte
    addi t2, t0, 0x24
    mv t3, a0
    2:
        // TODO: implement logic to copy 256 bytes in loop in address started at a0 
    2:
    ret

Syscall_read_sensor_distance:
    li t0, BASE_ADDRESS
    lw a0, 0x1C(t0)
    ret

Syscall_get_position:
    li t0, BASE_ADDRESS
    li t1, 1
    sb t1, (t0)
    lw a0, 0x10(t0)
    lw a2, 0x18(t0)
    ret
//----------------------------------------------------------------------------------------
int_handler:
  li t0, SYSCALL_SET_MOTOR
  beq a7, t0, Syscall_set_motor

  li t0, SYSCALL_SET_HANDBREAK
  beq a7, t0, Syscall_set_handbreak
  
  li t0, SYSCALL_GET_POSITION
  beq a7, t0, Syscall_get_position
  
  1:
  csrr t0, mepc  # carrega endereço de retorno (endereço da instrução que invocou a syscall)  
  addi t0, t0, 4 # soma 4 no endereço de retorno (para retornar após a ecall) 
  csrw mepc, t0  # armazena endereço de retorno de volta no mepc
  mret           # recupera o restante do contexto (pc <- mepc)
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
    # setting program stack
    li sp, STACK_POINTER_BASE_ADDRESS
    la t0, stack
    csrw mscratch, t0
    # calling main function
    # (loading the user software entry point into mepc)
    la t0, main  
    csrw mepc, t0
    mret