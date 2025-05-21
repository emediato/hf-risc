## UART Implementation for MIPS with Synchronized Baud Rate

Configurable baud rate, data bits, stop bits, and parity
Separate RX and TX modules with proper state machines
Input synchronization to prevent metastability
Error detection for parity and framing errors
Clean separation of timing and state logic

## MIPS Memory-Mapped Interface in VHDL

Maps UART registers to memory addresses (base 0x10000000)
Provides data, status, control, and baud rate registers
Handles read/write operations from the MIPS processor
Properly synchronizes between MIPS memory bus and UART timing
Sets default baud rate to 115200 (50MHz/434) for reliable communication

## C Code for UART Communication
The third artifact provides C code for the MIPS processor to communicate through the UART:

Functions for initialization, sending, and receiving data
Matching memory-mapped register definitions
Configures the same baud rate (115200) as the VHDL implementation
Includes a synchronization protocol to ensure both sides are ready
Contains examples for common operations like sending strings and echoing characters

## Key Points for Synchronization
For properly synchronized communication:

### Matching Baud Rate: Both VHDL and C code use the same baud rate calculation:

System clock: 50MHz
Baud rate: 115200
Divider value: 434 (50,000,000 ÷ 115,200)

### Handshaking Protocol: The C code includes a synchronization function that:

Sends a sync byte (0xAA)
Waits for acknowledgment (0x55)
Times out if no response is received

### Status Monitoring: The code properly checks UART status registers before attempting transmission or reception to prevent data loss
