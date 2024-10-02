# MIPS WAV File Processing Project

## Introduction
This project consists of four MIPS assembly programs that manipulate `.wav` files. Each program performs a specific operation related to reading, analyzing, and modifying `.wav` files, including extracting metadata, identifying amplitude extremes, reversing audio data, and generating simple tones. The following sections describe each program and its functionality.

## Project Structure
### Files
- `Question1.asm` - Reads a `.wav` file and extracts important metadata like the number of channels, sample rate, byte rate, and bits per sample.
- `Question2.asm` - Identifies and prints the maximum and minimum amplitude from the `.wav` file's audio data.
- `Question3.asm` - Reverses the audio data of a `.wav` file and writes the reversed data to a new file.
- `Question4.asm` - Generates a new `.wav` file with alternating high and low tones.

### Dependencies
These programs run on MIPS architecture. You will need an appropriate MIPS emulator (e.g., MARS or SPIM) to compile and execute the assembly code. Ensure that your environment supports file input/output syscalls.

## Program Descriptions

### 1. **Question1: Extract WAV File Metadata**
This program reads a `.wav` file and extracts the following metadata:
- Number of channels
- Sample rate
- Byte rate
- Bits per sample

#### Key Operations:
- Prompts the user for the `.wav` file name.
- Opens the file and reads the first 44 bytes of the file header.
- Extracts metadata from specific byte positions in the header and prints them to the console.

#### Usage:
1. Enter the name of the `.wav` file.
2. Enter the file size.
3. The program will output the number of channels, sample rate, byte rate, and bits per sample.

### 2. **Question2: Find Maximum and Minimum Amplitude**
This program scans the audio data of a `.wav` file and finds the maximum and minimum amplitude values.

#### Key Operations:
- Prompts the user for the `.wav` file name and file size.
- Reads the audio data (skipping the 44-byte header) and finds the maximum and minimum amplitude values.
- Outputs these amplitude values to the console.

#### Usage:
1. Enter the `.wav` file name and its size.
2. The program will output the maximum and minimum amplitude values in the audio data.

### 3. **Question3: Reverse WAV File Audio**
This program reverses the audio data of a `.wav` file and writes it to a new file.

#### Key Operations:
- Prompts the user for the input `.wav` file and output file names.
- Reads the file's audio data, reverses it, and writes the reversed data to a new file.
  
#### Usage:
1. Enter the input file name, followed by the output file name.
2. The reversed audio is written to the specified output `.wav` file.

### 4. **Question4: Generate a Simple WAV File**
This program generates a `.wav` file with alternating high and low tones for a specified duration.

#### Key Operations:
- Prompts the user for the output file name and generates a `.wav` file with alternating high and low tones.
- The program calculates the length and size of the tones and writes them to a new file.
  
#### Usage:
1. Enter the output file name.
2. The program generates a tone sequence and writes it to the specified file.

## Execution
1. Run the MIPS programs using the MARS or SPIM simulator.
2. Input the required file names and sizes as prompted.
3. The output will be printed to the console, or a new `.wav` file will be created, depending on the program.

## Conclusion
This project demonstrates how to read, manipulate, and generate audio data in `.wav` files using MIPS assembly. The four programs provide a foundational approach to working with audio files at the byte level, including metadata extraction, amplitude analysis, audio reversal, and tone generation.
