//--------------------------------------------------------------
.data
    imagePath: .asciz "imagem.pgm"
    maxImageSize: .word 262159
//--------------------------------------------------------------
.bss
    image: .skip 262159
//--------------------------------------------------------------
.text

openImage:
    # a0 -> image path
    # a1 -> flags (0: rdonly, 1: wronly, 2: rdwr)
    # a2 -> mode
    # a7 -> syscall number
    la a0, imagePath
    li a1, 0
    li a2, 0
    li a7, 1024
    ecall
    ret
//--------------------------------------------------------------
readImage:
    # a0 -> file descriptor (read in openImage)
    # a1 -> memory address to save data
    # a2 -> size of data to save in memory
    # a7 -> syscall number
    la a1, image
    lw a2, maxImageSize
    li a7, 63
    ecall
    ret
//--------------------------------------------------------------
setCanvasSize:
    # a0 -> image width
    # a1 -> image height
    # a7 -> syscall number
    li a7, 2201
    ecall
    ret
//--------------------------------------------------------------
getImageSize:
    # s1 -> address of second line of image file begin
    # t0 -> auxiliar variable for read second line of image file from end to begin
    # t1 -> byte read from memory
    # t2 -> ascii code for character '\n' (breakline)
    # t3 -> ascii code for character ' ' (space)
    # t4 -> auxiliar variable for get decimal value of characters
    # t5 -> auxiliar variable for get decimal value of characters
    # t6 -> decimal value of some image size
    # a0 -> image width
    # a1 -> image height
    li t2, 10
    1:
        # getting index of '\n' in second line of image file
        lbu t1, 0(s1)
        beq t1, t2, 1f
        addi s1, s1, 1
        j 1b
    1:
        # copy index of '\n', saved in s1, in t0
        mv t0, s1
        li t3, 32
        li t4, 1
        li t5, 10
        li t6, 0
        2:
            # readind bytes from end to begin of second line of image file
            addi t0, t0, -1
            lbu t1, 0(t0)
            # checking if read ' ' or '\n'
            beq t1, t3, 3f
            beq t1, t2, 4f
            # calculate decimal value of character read
            addi t1, t1, -48
            mul t1, t1, t4
            # increment magnitude order of byte read
            mul t4, t4, t5
            # adding decimal value of byte in t6
            add t6, t6, t1
            # keep in loop
            j 2b
        3:
            # case read ' '
            #   --> save t6 (image height) in a1 and reset registers t6 and t4
            mv a1, t6
            li t6, 0
            li t4, 1
            j 2b
        4:
            # case read '\n'
            #   --> save t6 (image width) in a0 and return
            mv a0, t6
            j getImageSizeReturn
//--------------------------------------------------------------
printImage:
    # s2 -> image width  (columns of image matrix)
    # s3 -> image height (lines of image matrix)
    # a0 -> control variable for columns in matrix
    # a1 -> control variable for lines in matrix
    # a7 -> syscall number
    mv s2, a0
    mv s3, a1
    li a0, -1
    li a1, -1
    1:
        beq a1, s3, 1f
        addi a1, a1, 1
    2:
        beq a0, s2, 2f
        # loading byte from image from memory
        lbu t0, 0(s1)
        # adjusting looping control variables
        addi s1, s1, 1
        addi a0, a0, 1
        # getting pixel model R|G|B|A and saving it in a2
        li a2, 0
        add a2, a2, t0
        slli a2, a2, 8
        add a2, a2, t0
        slli a2, a2, 8
        add a2, a2, t0
        slli a2, a2, 8
        add a2, a2, 0xFF
        # printing pixel with Canvas
        li a7, 2200
        ecall
        # keep in loop
        j 2b
    2:
        # go to the next line
        li a0, 0
        j 1b
    1:
        ret
//--------------------------------------------------------------
end:
    # a0 -> exit code
    # a7 -> syscall number
    li a0, 0
    li a7, 93
    ecall
    ret
//--------------------------------------------------------------
.globl _start

_start:
    jal openImage

    jal readImage

    # loading image address in register
    la s1, image
    addi s1, s1, 3 # to read second line of image file

    jal getImageSize
    getImageSizeReturn:

    addi s1, s1, 5 # to read fourth line of image file

    # Setting Canvas Size
    jal setCanvasSize
    
    # Printing image with Canvas
    jal printImage

    # finish program
    jal end