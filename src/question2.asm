.data
     prompt_maxAmp: .asciiz "Maximum amplitude: "
    prompt_minAmp: .asciiz "\nMinimum amplitude: "
    prompt_filename: .asciiz "Enter a wave file name:\n"
    prompt_filesize: .asciiz "Enter the file size (in bytes):\n"
    prompt_introText: .asciiz "Information about the wave file:\n================================\n"
   
    filename: .space 256   # Buffer for file name
    temp: .space 256
    filesize: .space 10

.text
.globl main
main:
      # prompt for file name
        li $v0, 4
        la $a0, prompt_filename
        syscall

        #<file name>
        li $v0, 8
        la $a0, temp
        li $a1, 256
        syscall

        # Print prompt for file size
        li $v0, 4
        la $a0, prompt_filesize
        syscall

        # Get file size
        li $v0, 5
        syscall
        move $s1, $v0  #storing file size in $s1

        #print out intro text
        la $a0, prompt_introText
        li $v0, 4
        syscall

        la $t0, temp
        la $t1, filename

format:
    lb $t2, 0($t0)
    beq $t2, 10, continue
    sb $t2, 0($t1)
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j format


continue:
    sb $zero, 0($t1)
        # Open file for reading
        li $v0, 13         
        la $a0, filename   
        li $a1, 0          
        li $a2, 0          
        syscall
        move $s0, $v0      

        
        move $a0, $s1       
        li $v0, 9          
        syscall
        move $s2, $v0      

        # Read file
        li $v0, 14         
        move $a0, $s0      
        move $a1, $s2     
        move $a2, $s1        
        syscall

        li $s3, -32768 
        li $s4, 32767  

        addi $s5, $s1, -44 
        addi $s2, $s2, 44 

        Loop:
            beqz $s5, PrintOut
            lh $t3, 0($s2)
            bgt $t3, $s3, NewMax
            blt $t3, $s4, NewMin

            j NextItteration

       NewMax:
            move $s3, $t3
            blt $t3, $s4, NewMin
            j NextItteration
       NewMin:
            move $s4, $t3
            j NextItteration
       NextItteration:
        addi $s2, $s2, 2
        addi $s5, $s5, -2
        j Loop

    PrintOut:
    #printing max amplitude text
        li $v0, 4
        la $a0, prompt_maxAmp
        syscall

        li $v0, 1
        move $a0, $s3
        syscall

        li $v0, 4
        la $a0, prompt_minAmp
        syscall

        li $v0, 1
        move $a0, $s4
        syscall

    li $v0, 10
    syscall
