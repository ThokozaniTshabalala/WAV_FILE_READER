.data
    .align 2                  # Ensure alignment to 4-byte boundary
    prompt_filepath: .asciiz "Enter the full path to the WAV file:\n"
    prompt_filesize: .asciiz "Enter the file size (in bytes):\n"
    output_header:   .asciiz "\nInformation about the wave file:\n"
    output_channels: .asciiz "Number of channels: "
    output_samplerate: .asciiz "Sample rate: "
    output_byterate: .asciiz "Byte rate: "
    output_bitspersample: .asciiz "Bits per sample: "
    newline: .asciiz "\n"
    file_open_success_msg: .asciiz "File opened successfully.\n"
    read_file_msg: .asciiz "Attempting to read file...\n"
    file_read_success_msg: .asciiz "File read successfully.\n"
    open_file_error_msg: .asciiz "Failed to open the file.\n"
    read_file_error_msg: .asciiz "Failed to read the file.\n"
    error_code_msg: .asciiz "Error code: "
    invalid_wav_msg: .asciiz "Invalid WAV file format.\n"
    invalid_size_msg: .asciiz "Invalid file size. Please enter a positive number.\n"
    
    filepath_buffer: .space 256  # Buffer to store user-input file path
    header_buffer: .space 44     # Allocates 44 bytes for the header

    # Debug messages
    debug_msg1: .asciiz "Debug: About to verify WAV format\n"
    debug_msg2: .asciiz "Debug: Header buffer address: "
    debug_msg3: .asciiz "Debug: RIFF check passed\n"
    debug_msg4: .asciiz "Debug: WAVE check passed\n"
    debug_msg5: .asciiz "Debug: Starting to parse WAV header\n"

.text
.globl main

main:
    # Prompt user for file path
    li $v0, 4
    la $a0, prompt_filepath
    syscall

    # Read file path from user
    li $v0, 8
    la $a0, filepath_buffer
    li $a1, 256
    syscall

    # Remove newline character from input
    la $t0, filepath_buffer
remove_newline:
    lb $t1, ($t0)
    beqz $t1, end_remove_newline
    bne $t1, 10, next_char
    sb $zero, ($t0)
    j end_remove_newline
next_char:
    addi $t0, $t0, 1
    j remove_newline
end_remove_newline:

    # Prompt for file size
    li $v0, 4
    la $a0, prompt_filesize
    syscall

    # Read file size
    li $v0, 5
    syscall
    move $t0, $v0  # Store file size in $t0

    # Check if file size is valid (positive)
    blez $t0, invalid_size_error

    # Open the file
    li $v0, 13                # syscall for file open
    la $a0, filepath_buffer   # file path
    li $a1, 0                 # read-only mode
    li $a2, 0                 # ignored
    syscall
    move $s0, $v0             # save file descriptor in $s0

    # Check for open error
    bltz $s0, open_file_error_handler

    # Print file opened successfully
    li $v0, 4
    la $a0, file_open_success_msg
    syscall

    # Read WAV header (44 bytes)
    li $v0, 14                # syscall for file read
    move $a0, $s0             # file descriptor
    la $a1, header_buffer     # buffer to hold header
    li $a2, 44                # read 44 bytes
    syscall

    # Check if read was successful
    bne $v0, 44, read_file_error_handler

    # Print file read successfully
    li $v0, 4
    la $a0, file_read_success_msg
    syscall

    # Close the file
    li $v0, 16
    move $a0, $s0
    syscall

    # Debug output
    li $v0, 4
    la $a0, debug_msg1
    syscall

    # Verify WAV format
    la $t0, header_buffer
    
    # Debug output
    li $v0, 4
    la $a0, debug_msg2
    syscall
    
    li $v0, 1
    move $a0, $t0
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall

    # Check "RIFF" - load byte by byte
    lbu $t2, 0($t0)
    lbu $t3, 1($t0)
    sll $t3, $t3, 8
    or $t2, $t2, $t3
    lbu $t3, 2($t0)
    sll $t3, $t3, 16
    or $t2, $t2, $t3
    lbu $t3, 3($t0)
    sll $t3, $t3, 24
    or $t2, $t2, $t3

    # Load "RIFF" for comparison
    li $t3, 0x52494646  # ASCII for "RIFF"

    bne $t2, $t3, invalid_wav_error
    
    # Debug output
    li $v0, 4
    la $a0, debug_msg3
    syscall

    # Check "WAVE" - load byte by byte
    lbu $t2, 8($t0)
    lbu $t3, 9($t0)
    sll $t3, $t3, 8
    or $t2, $t2, $t3
    lbu $t3, 10($t0)
    sll $t3, $t3, 16
    or $t2, $t2, $t3
    lbu $t3, 11($t0)
    sll $t3, $t3, 24
    or $t2, $t2, $t3

    # Load "WAVE" for comparison
    li $t3, 0x57415645  # ASCII for "WAVE"

    bne $t2, $t3, invalid_wav_error

    # Debug output
    li $v0, 4
    la $a0, debug_msg4
    syscall

    # Debug output
    li $v0, 4
    la $a0, debug_msg5
    syscall

    # Parse WAV header
    # Number of Channels (2 bytes at offset 22)
    lbu $t1, 22($t0)
    lbu $t2, 23($t0)
    sll $t2, $t2, 8
    or $s1, $t1, $t2          # $s1 = Number of Channels

    # Sample Rate (4 bytes at offset 24)
    lbu $t1, 24($t0)
    lbu $t2, 25($t0)
    sll $t2, $t2, 8
    or $s2, $t1, $t2
    lbu $t1, 26($t0)
    sll $t1, $t1, 16
    or $s2, $s2, $t1
    lbu $t1, 27($t0)
    sll $t1, $t1, 24
    or $s2, $s2, $t1          # $s2 = Sample Rate

    # Byte Rate (4 bytes at offset 28)
    lbu $t1, 28($t0)
    lbu $t2, 29($t0)
    sll $t2, $t2, 8
    or $s3, $t1, $t2
    lbu $t1, 30($t0)
    sll $t1, $t1, 16
    or $s3, $s3, $t1
    lbu $t1, 31($t0)
    sll $t1, $t1, 24
    or $s3, $s3, $t1          # $s3 = Byte Rate

    # Bits per Sample (2 bytes at offset 34)
    lbu $t1, 34($t0)
    lbu $t2, 35($t0)
    sll $t2, $t2, 8
    or $s4, $t1, $t2          # $s4 = Bits per Sample

    # Print WAV information
    li $v0, 4
    la $a0, output_header
    syscall

    li $v0, 4
    la $a0, output_channels
    syscall
    li $v0, 1
    move $a0, $s1
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    li $v0, 4
    la $a0, output_samplerate
    syscall
    li $v0, 1
    move $a0, $s2
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    li $v0, 4
    la $a0, output_byterate
    syscall
    li $v0, 1
    move $a0, $s3
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    li $v0, 4
    la $a0, output_bitspersample
    syscall
    li $v0, 1
    move $a0, $s4
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    # Exit program
    li $v0, 10
    syscall

open_file_error_handler:
    li $v0, 4
    la $a0, open_file_error_msg
    syscall
    li $v0, 4
    la $a0, error_code_msg
    syscall
    li $v0, 1
    move $a0, $s0
    syscall
    j exit_program

read_file_error_handler:
    li $v0, 4
    la $a0, read_file_error_msg
    syscall
    j exit_program

invalid_wav_error:
    li $v0, 4
    la $a0, invalid_wav_msg
    syscall
    j exit_program

invalid_size_error:
    li $v0, 4
    la $a0, invalid_size_msg
    syscall
    j exit_program

exit_program:
    li $v0, 10
    syscall