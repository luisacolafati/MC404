#-----------------------------------------------------------------------

.data
inputSize: .word 0x14
outputSize: .word 0x14
sqrtSize: .word 0x4

#-----------------------------------------------------------------------

.bss
input: .skip 0x14
output: .skip 0x14
sqrt: .skip 0x4

#-----------------------------------------------------------------------
.text

readInput: 
    li a0, 0          # file descriptor = 0 (stdin)
    la a1, input      # saving input address in a1
    la a2, inputSize  # saving input size in a2
    li a7, 63         # 63 = command to system read bytes from console
    ecall
    ret

invertSqrtBytes:
    # loading sqrt address
    la a1, sqrt
    # loading bytes from sqrt address
    lb t0, 0(a1)
    lb t1, 1(a1)
    lb t2, 2(a1)
    lb t3, 3(a1)
    # saving bytes in reverse order
    sb t3, 0(a1)
    sb t2, 1(a1)
    sb t1, 2(a1)
    sb t0, 3(a1)
    # return
    ret

saveSqrtInOutput:
    # getting sqrt bytes
    la a1, sqrt
    lb t0, 0(a1)
    lb t1, 1(a1)
    lb t2, 2(a1)
    lb t3, 3(a1)
    # getting output offset to save sqrt bytes
    la a2, output
    add a2, a2, t5
    addi a2, a2, -4
    # saving sqrt bytes in output string
    sb t0, 0(a2)
    sb t1, 1(a2)
    sb t2, 2(a2)
    sb t3, 3(a2)
    # adding space between squares
    li t1, 32
    sb t1, 4(a2)
    # return
    ret

writeOutput:
    # adding \n in end of output string
    la a2, output
    li t1, 10
    sb t1, 19(a2)
    # print output
    li a0, 1
    la a1, output
    la a2, outputSize
    li a7, 64
    ecall
    ret

getSqrtByBabylonianMethod:
    # s0 = y = decimal value to get square root
    li t0, 2
    divu t1, s0, t0
    # iteractions of Babylonian Method
    li t6, 0
    while:
        # exit while loop after 10 iteractions
        li t0, 10
        bge t6, t0, continue
        # calculating estimate root
        li t0, 2
        divu t2, s0, t1  # t2 = y / k = s0 / t1
        add t3, t1, t2   # t3 = k + y / k = t1 + t2
        divu t4, t3, t0  # t4 = (k + y / k) / 2 = t3 / t0
        addi t1, t4, 0   # saving estimate root (t4) in t1 
        # increment number of iteractions
        addi t6, t6, 1
        # keep in while loop
        jal while
    continue:
        # converting decimal value of estimate root (t4) in string to be print in console
        li t6, 0
        la a1, sqrt
        while2:
            # skip while loop after 4 iteractions
            li t1, 4
            beq t6, t1, continue2
            # converting decimal to character
            li t1, 10
            rem t2, t4, t1
            addi t2, t2, 48
            sb t2, 0(a1)
            li t1, 10
            div t4, t4, t1
            # adjusting while loop variables
            addi a1, a1, 1
            addi t6, t6, 1
            # keep in loop
            jal while2
        continue2:
            jal invertSqrtBytes
            jal saveSqrtInOutput
            jal resetForParams
            jal backToStart

resetForParams:
    li s0, 0
    li s1, 1000
    ret

end:
    li a0, 0
    li a7, 93 # 93 = command to system finish a program
    ecall
#-----------------------------------------------------------------------

.globl _start
_start:
    jal readInput

    li s0, 0
    li s1, 1000
    li s2, 10

    li t5, 0
    for:
        # exit loop if finish input reading
        li t1, 20
        beq t5, t1, exitFor

        # load input address in a1
        la a1, input
        add a1, a1, t5
        
        # load input character in t2
        lb s3, 0(a1)

        # calculate square root if t2 = '\n'
        li t1, 10
        beq s3, t1, getSqrtByBabylonianMethod
        
        # calculate square root if t2 is ' '
        li t1, 32
        beq s3, t1, getSqrtByBabylonianMethod
        
        addi s3, s3, -48
        mul s3, s3, s1
        div s1, s1, s2
        add s0, s0, s3

        backToStart:
        addi t5, t5, 1
        jal for
    
    exitFor:
        jal writeOutput
        jal end
