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
setBlackPixel:
    li t4, 0
    j printPixel

setWhitePixel:
    li t4, 255
    j printPixel

printImage:
    # s2 -> image width  (columns of image matrix)
    # s3 -> image height (lines of image matrix)
    # a0 -> control variable for columns in matrix
    # a1 -> control variable for lines in matrix
    # a7 -> syscall number
    # t0 -> byte read from memory
    mv s2, a0
    mv s3, a1
    li a0, -1
    li a1, -1

    # border number
    # t1 -> left and top border
    # t2 -> right border
    # t3 -> bottom border
    li t1, 0
    addi t2, s2, -1
    addi t3, s3, -1

    1:
        addi a1, a1, 1
        beq a1, s3, 1f
    2:
        addi a0, a0, 1
        beq a0, s2, 2f
        
        # loading byte from image from memory
        lbu t0, 0(s1)

        # case pixel is from top or bottom border
        beq a1, t1, setBlackPixel
        beq a1, t3, setBlackPixel
        # case pixel is from left or right border
        beq a0, t1, setBlackPixel
        beq a0, t2, setBlackPixel
        
        # ----------------------------------------------------
        
        # applyinf filter in pixels
        
        # positions in w matrix of filter
        mv s5, s2
        li t5, -1
        mul s5, s5, t5 # s5 = -s2

        add s5, s5, s1  # w[0][1]
        addi s4, s5, -1 # w[0][0]
        addi s6, s5, 1  # w[0][2]

        addi s7, s1, -1 # w[1][0]
        addi s8, s1, 1  # w[1][2]

        add s10, s1, s2  # w[2][1]
        addi s9, s10, -1 # w[2][0]
        addi s11, s10, 1 # w[2][2]

        # calculating new pixel value:
        li t4, 0
        ## multiplying the current pixel value by 8
        li t5, 8
        mul t0, t0, t5
        add t4, t4, t0
        ## subtracting value from neighboring pixels
        li t5, -1
        ### top left
        lbu t0, 0(s4)
        mul t0, t0, t5
        add t4, t4, t0
        ### top
        lbu t0, 0(s5)
        mul t0, t0, t5
        add t4, t4, t0
        ### top right
        lbu t0, 0(s6)
        mul t0, t0, t5
        add t4, t4, t0
        ### left
        lbu t0, 0(s7)
        mul t0, t0, t5
        add t4, t4, t0
        ### right
        lbu t0, 0(s8)
        mul t0, t0, t5
        add t4, t4, t0
        ### bottom left
        lbu t0, 0(s9)
        mul t0, t0, t5
        add t4, t4, t0
        ### bottom
        lbu t0, 0(s10)
        mul t0, t0, t5
        add t4, t4, t0
        ### bottom right
        lbu t0, 0(s11)
        mul t0, t0, t5
        add t4, t4, t0
        ## case pixel < 0
        bltz t4, setBlackPixel
        ## case pixel > 255
        li t5, 255
        bgt t4, t5, setWhitePixel

        # ----------------------------------------------------
        printPixel:
        # getting pixel model R|G|B|A and saving it in a2
        li a2, 0
        add a2, a2, t4
        slli a2, a2, 8
        add a2, a2, t4
        slli a2, a2, 8
        add a2, a2, t4
        slli a2, a2, 8
        add a2, a2, 0xFF
        
        # printing pixel with Canvas
        li a7, 2200
        ecall
        
        # keep in loop
        addi s1, s1, 1
        j 2b
    2:
        # go to the next line
        li a0, -1
        j 1b
    1:
        j end
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