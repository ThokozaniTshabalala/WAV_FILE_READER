.data
#.align2 ---if there is an issue with loading the header again comment this out
    prompt_filename: .asciiz "Enter a wave file name:\n"
   output_channels: .asciiz "Number of channels: "
   output_bitspersample: .asciiz "\nBits per sample: "
   filename: .space 256   # Buffer for file name
    prompt_filesize: .asciiz "Enter the file size (in bytes):\n"
    prompt_introText: .asciiz "Information about the wave file:\n================================\n"
    output_samplerate: .asciiz "\nSample rate: "
    output_byterate: .asciiz "\nByte rate: "
    temp: .space 256
    filesize: .space 50     # Space for file size
    .align 2
    header: .space 44

.text
.globl main
    main:
        # Print prompt for file name
        # Print <--debug everything-->
        li $v0, 4
        la $a0, prompt_filename
        syscall

        # Get file name
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
        #sw $v0, filesize   # Store file size in memory

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
        li $v0, 13         # Open file syscall
        la $a0, filename   # Pass file name
        li $a1, 0          # Read-only mode
        li $a2, 0          # No permissions needed
        syscall
        move $t0, $v0      # Store file descriptor in $t0

        # Read WAVE header (44 bytes)
        li $v0, 14         # Read syscall
        move $a0, $t0      # File descriptor
        la $a1, header     # Buffer for header
        li $a2, 44         # Read 44 bytes (header size)
        syscall

        move $s1, $a1
        # Extract number of channels (bytes 22-23)
        #.align 2
        lh $t1, 22($s1)
        #lh $t2, 23($a1)
        #sll $t2, $t2, 8    # Shift upper byte
        #or $t1, $t1, $t2   # Combine bytes

        # Print number of channels
        li $v0, 4
        la $a0, output_channels
        syscall
        li $v0, 1
        move $a0, $t1
        syscall

        # Extract sample rate (bytes 24-27)
        lw $t3, 24($s1)    # Load word from bytes 24-27

        # Print sample rate
        li $v0, 4
        la $a0, output_samplerate
        syscall
        li $v0, 1
        move $a0, $t3
        syscall

        # Extract byte rate (bytes 28-31)
        lw $t4, 28($s1)    # Load word from bytes 28-31

        # Print byte rate
        li $v0, 4
        la $a0, output_byterate
        syscall
        li $v0, 1
        move $a0, $t4
        syscall

        # Extract bits per sample (bytes 34-35)
       
        lh $t5, 34($s1)
        #lh $t6, 35($a1)
        #sll $t6, $t6, 8
        #or $t5, $t5, $t6

        # Print bits per sample
        li $v0, 4
        la $a0, output_bitspersample
        syscall
        li $v0, 1
        move $a0, $t5
        syscall

        # Close the file
        li $v0, 16
        move $a0, $t0      # File descriptor
        syscall

        # Exit program
        li $v0, 10
        syscall
