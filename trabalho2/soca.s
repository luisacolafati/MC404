.bss
stack:
//----------------------------------------------------------------------------------------
.text
//----------------------------------------------------------------------------------------
.set STACK_POINTER_ADDRESS, 0x07FFFFFC
.set SELF_DRIVING_CAR_ADDRESS, 0xFFFF0300
.set SERIAL_IO_ADDRESS, 0xFFFF0500
.set CANVAS_ADDRESS, 0xFFFF0700

.set GOAL_X_COORD, 73
.set GOAL_Z_COORD, -19

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
returnInvalidParamError:
    li a0, -1
    j restoreContextAndFinishSyscall
//----------------------------------------------------------------------------------------
Syscall_set_motor:
    # validating params received (a0 and a1)
    ## case a0 is outside valid range [-1, 1]
    li t0, -1
    blt a0, t0, returnInvalidParamError
    li t0, 1
    bgt a0, t0, returnInvalidParamError
    ## case a1 is outside valid range [-127, 127]
    li t0, -127
    blt a1, t0, returnInvalidParamError
    li t0, 127
    bgt a1, t0, returnInvalidParamError
    # changing movement direction ang angle
    li t0, SELF_DRIVING_CAR_ADDRESS
    sb a0, 0x21(t0)
    sb a1, 0x20(t0)
    li a0, 0
    j restoreContextAndFinishSyscall

Syscall_set_handbreak:
    # validating param received (a0)
    ## case a0 != 0 && a0 != 1
    li t0, 0
    blt a0, t0, returnInvalidParamError
    li t0, 1
    bgt a0, t0, returnInvalidParamError
    # setting handbreak
    li t0, SELF_DRIVING_CAR_ADDRESS
    sb a0, 0x22(t0)
    li a0, 0
    j restoreContextAndFinishSyscall

Sycall_read_sensors:
    li t0, SELF_DRIVING_CAR_ADDRESS
    # activate line camera to register image
    li t1, 1
    sb t1, 0x01(t0)
    # waiting camera capture image
    2:
    lb t1, 0x01(t0)
    bnez t1, 2b
    # readind each byte captured by camera in memory
    ## a0 -> memory address to store byte
    ## t2 -> byte read from memory
    ## t5 -> control variable for read 256 bytes in loop
    ## t6 -> control variable for read 256 bytes in loop
    li t5, 0
    li t6, 256
    2:
    lbu t2, 0x24(t0)
    sb t2, (a0)
    addi t0, t0, 1
    addi a0, a0, 1
    addi t5, t5, 1
    bne t5, t6, 2b
    j restoreContextAndFinishSyscall

Syscall_read_sensor_distance:
    li t0, SELF_DRIVING_CAR_ADDRESS
    # activate ultrasonic sensor to measure distance
    li t1, 1
    sb t1, 0x02(t0)
    # waiting for ultrasonic sensor measure
    2:
    lb t1, 0x02(t0)
    bnez t1, 2b
    # reading ultrasonic sensor measure from memory
    lw a0, 0x1C(t0)
    j restoreContextAndFinishSyscall

Syscall_get_position:
    li t0, SELF_DRIVING_CAR_ADDRESS
    # activate GPS
    li t1, 1
    sb t1, 0(t0)
    # waiting for measure
    2:
    lb t1, 0(t0)
    bnez t1, 2b
    # reading GPS measure from memory
    lw t1, 0x10(t0)
    sw t1, 0(a0)
    lw t1, 0x14(t0)
    sw t1, 0(a1)
    lw t1, 0x18(t0)
    sw t1, 0(a2)
    j restoreContextAndFinishSyscall

Syscall_get_rotation:
    li t0, SELF_DRIVING_CAR_ADDRESS
    # activate GPS
    li t1, 1
    sb t1, 0(t0)
    # waiting for measure
    2:
    lb t1, 0(t0)
    bnez t1, 2b
    # reading GPS measure from memory
    lw t1, 0x04(t0)
    sw t1, 0(a0)
    lw t1, 0x08(t0)
    sw t1, 0(a1)
    lw t1, 0x0C(t0)
    sw t1, 0(a2)
    j restoreContextAndFinishSyscall

Syscall_read:
    # a1 -> buffer to read
    li t0, SERIAL_IO_ADDRESS
    li t1, 10 # breakline character
    li t2, 32 # space character
    li a0, 0  # number of bytes read
    2:
    # triggers the serial port to read
    li t3, 1
    sb t3, 0x02(t0)
    # waiting for serial port
    3:
    lb t3, 0x02(t0)
    bnez t3, 3b
    # reading byte from serial port
    lb t3, 0x03(t0)
    # ignoring empty spaces
    beq t3, t2, 4f
    # storing byte read
    sb t3, 0(a1)
    addi a1, a1, 1
    4:
    addi a0, a0, 1
    bne t3, t1, 2b
    # exit if read '\n'
    sb zero, -1(a1) # before, save 0 in end of buffer
    j restoreContextAndFinishSyscall

Syscall_write:
    # a1 -> buffer to write
    li t0, SERIAL_IO_ADDRESS
    li t1, 10 # breakline character
    2:
    # skip loop if read 0 (end of buffer) 
    lb t2, 0(a1)
    beqz t2, 4f
    # saving buffer byte in serial port 
    lb t2, 0x02(t0)
    # triggers the serial port to write
    li t3, 1
    sb t3, 0(t0)
    # waiting for serial port
    3:
    lb t3, 0(t0)
    bnez t3, 3b
    # reading next byte in buffer
    addi a1, a1, 1
    j 2b
    4:
    # adding breakline in end of buffer
    lb t1, 0x02(t0)
    li t3, 1
    sb t3, 0(t0)
    5:
    lb t3, 0(t0)
    bnez t3, 5b
    # finishing writing
    j restoreContextAndFinishSyscall

Syscall_draw_line:
    li t0, CANVAS_ADDRESS
    # reading array with 504 bytes started at a0 in Canvas memory
    li t1, 0
    li t2, 504
    li t3, 0xFF
    2:
    lbu t4, 0(a0)
    # store byte as R|G|B|A pattern in Canvas words
    sb t4, 0(t0)
    sb t4, 1(t0)
    sb t4, 2(t0)
    sb t3, 3(t0)
    # adjusting loop control variables for read next byte in memory and save it in next Canvas word
    addi a0, a0, 1
    addi t0, t0, 4
    addi t1, t1, 4
    # keep in loop until reading all 504 bytes from memory
    bne t1, t2, 2b
    # activate Canvas
    li t1, 1
    sb t1, 0(t0)
    # waiting for Canvas draw line
    2:
    lb t1, 0(t0)
    bnez t1, 2b
    j restoreContextAndFinishSyscall

Syscall_get_systime:
    li t0, SELF_DRIVING_CAR_ADDRESS
    # activate GPS
    li t1, 1
    sb t1, 0(t0)
    # waiting for measure
    2:
    lb t1, 0(t0)
    bnez t1, 2b
    # reading GPS measure from memory
    lw a0, 0x04(t0)
    j restoreContextAndFinishSyscall
//----------------------------------------------------------------------------------------
int_handler:
    li t0, SYSCALL_SET_MOTOR
    beq a7, t0, Syscall_set_motor

    li t0, SYSCALL_SET_HANDBREAK
    beq a7, t0, Syscall_set_handbreak

    li t0, SYSCALL_READ_SENSORS
    beq a7, t0, Sycall_read_sensors

    li t0, SYSCALL_READ_SENSOR_DISTANCE
    beq a7, t0, Syscall_read_sensor_distance

    li t0, SYSCALL_GET_POSITION
    beq a7, t0, Syscall_get_position

    li t0, SYSCALL_GET_ROTATION
    beq a7, t0, Syscall_get_rotation

    li t0, SYSCALL_READ
    beq a7, t0, Syscall_read

    li t0, SYSCALL_WRITE
    beq a7, t0, Syscall_write

    li t0, SYSCALL_DRAW_LINE
    beq a7, t0, Syscall_draw_line

    li t0, SYSCALL_GET_SYSTIME
    beq a7, t0, Syscall_get_systime

    restoreContextAndFinishSyscall:
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
    li sp, STACK_POINTER_ADDRESS
    la t0, stack
    csrw mscratch, t0
    # calling main function
    # (loading the user software entry point into mepc)
    la t0, main  
    csrw mepc, t0
    mret