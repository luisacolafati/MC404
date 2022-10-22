//--------------------------------------------------------------
.data
    imagePath: .asciz "imagem.pmg"
    maxImageSize: .word 0x400F
//--------------------------------------------------------------
.bss
    image: .skip 0x4000F
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

    getImageSize:
        # t0 -> imagge address in memory
        # t1 -> some byte read from image in memory
        # t2 -> ascii code for characters to compare with t1
        # t3 -> decimal value of characters read
        la t0, image
        li a3, 0
        1:
            # loading byte from memory in t1
            lbu t1, 0(image)
            
            # case t1 == ' '
            #   save t3 in a0 and make t3 = 0
            li t2, 32
            bne t1, t2, 2f
            lw a0, t3
            li t3, 0

            # case t1 == '/n'
            #   save t3 in a1
            2:
            li t2, 10
            bne t1, t2, 3f
            lw a1, t3
            jal 1f
            
            # case t1 != ' ' and t1 !='/n'
            #   add decimal value of t1 in t3
            3:
            addi t1, t1, 48
            add t3, t3, ti
        1:
            ret

    setCanvasSize:
        # a0 -> image width  (between 0 and 512)
        # a1 -> image height (between 0 and 512)
        # a7 -> syscall number
        li a7, 2201
        ecall
        ret

    setPixel:
        # a0 -> x coordinate of pixel
        # a1 -> y coordinate of pixel
        # a2 -> pixel color (R|G|B|A) 
        # a7 -> syscall number
        li a7, 2200
        ecall
        ret

    writeImageInCanvas:
        // TODO: implement function
        ret
    
    end:
        li a0, 0
        li a7, 93
        ecall
//--------------------------------------------------------------
.globl _start
_start:
    jal openImage
    jal readImage
    jal getImageSize
    jal setCanvasSize
    jal writeImageInCanvas
    jal end