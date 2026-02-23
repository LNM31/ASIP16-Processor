# ASIP16-Processor

**A 16-bit general-purpose processor with tensor acceleration, built from the ground up in structural Verilog.**

![Verilog](https://img.shields.io/badge/Verilog-HDL-blue?style=flat-square)
![Icarus Verilog](https://img.shields.io/badge/Icarus%20Verilog-Simulation-orange?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Linux-green?style=flat-square)
![ISA](https://img.shields.io/badge/ISA-Custom%2016--bit-purple?style=flat-square)
![Instructions](https://img.shields.io/badge/Instructions-48+-red?style=flat-square)
![FSM States](https://img.shields.io/badge/FSM%20States-174-yellow?style=flat-square)

</div>

<div align="center">
  <img src="https://github.com/user-attachments/assets/437fbb45-74b1-484b-ac4d-4ee762d8110a" alt="CPU Architecture"/>
</div>

---

## Overview

ASIP16 is a fully functional 16-bit processor implemented entirely in structural Verilog — no behavioral shortcuts, no `always @(*)` case statements for control logic. Every control signal is derived from Boolean equations and gate-level instantiations.

The processor executes real programs loaded from memory, supports a complete instruction set with arithmetic, logic, branching, stack operations, and I/O — and then goes further. An **Application-Specific Instruction Processor (ASIP)** extension adds hardware-accelerated tensor operations: addition, subtraction, element-wise multiplication, and full **matrix multiplication** — all as single instructions that operate directly on memory-resident data structures.

The CPU Control Unit alone implements **174 one-hot FSM states** generating **123 control signals**, all built structurally with flip-flops and combinational logic. The ALU operates as a self-contained subsystem with its own dedicated FSM-based Control Unit handling multi-cycle operations like multiplication and division. The entire system is integrated into a System-on-Chip that coordinates the CPU, 512-word unified memory, and handshake-based I/O units under a single clock domain.

This isn't a textbook exercise — it's a working computer that can multiply matrices.

---

## Architecture

The processor follows a classical **accumulator-based architecture** inspired by the IAS machine, with a centralized control strategy and a unified memory space for both instructions and data.

```mermaid
graph TB
    subgraph SoC[System-on-Chip]
        direction TB

        subgraph CPU[CPU Core]
            direction LR

            subgraph CU[Control Unit - 174 states, 123 signals - One-Hot FSM]
            end

            subgraph DP[Datapath]
                direction TB
                PC[PC] --- IR[IR]
                AC[AC] --- FLAGS[FLAGS - N,Z,C,V]
                XY[X / Y] --- R2R9[R2 to R9 - ASIP]
                SP[SP] --- AR[AR]
                SEU[Sign Extend Unit]
            end

            subgraph ALU[ALU Subsystem]
                direction TB
                ALU_CU[ALU Control Unit - FSM, 19 signals]
                ALU_DP[A, Q, M Registers + RCA Adder + Counter]
                ALU_CU --- ALU_DP
            end

            CU -->|control vector| DP
            CU -->|start / ack| ALU
            DP ---|operands / results| ALU
        end

        MEM[Memory - 512 x 16-bit - Unified]
        INP[Input Unit - Handshake]
        OUT[Output Unit - Handshake]

        CPU ---|Data Bus + Address Bus + RD/WR| MEM
        CPU ---|inp_req / inp_ack| INP
        CPU ---|out_req / out_ack| OUT
    end
```

### Key Architectural Properties

| Property | Value |
|----------|-------|
| Word size | 16-bit |
| Instruction width | Fixed 16-bit |
| Memory | 512 × 16-bit, unified (von Neumann) |
| Address space | 9-bit (word-addressable) |
| Register file | AC, X, Y + R2–R9 (ASIP), PC, SP, AR, IR, FLAGS |
| ALU operations | ADD, SUB, MUL, DIV, MOD, AND, OR, XOR, NOT, shifts, rotates |
| Control strategy | Centralized, one-hot FSM (structural) |
| I/O model | Memory-mapped, handshake-based |
| Stack | Descending, managed by SP (initialized at address 512) |

---

## Instruction Set

48+ instructions organized into 6 encoding formats, covering memory operations, arithmetic/logic, branching, stack manipulation, I/O, and tensor acceleration.

### Memory Instructions

| Mnemonic | Description |
|----------|-------------|
| `LDR Reg, #Addr` | Load register (X or Y) from memory address |
| `LDA Reg, Offset` | Load accumulator from `Mem[Reg + Offset]` |
| `STR Reg, #Addr` | Store register to memory address |
| `STA Reg, Offset` | Store accumulator to `Mem[Reg + Offset]` |
| `LDA #Addr` | Load accumulator from direct memory address |
| `STA #Addr` | Store accumulator to direct memory address |

### Stack & I/O Instructions

| Mnemonic | Description |
|----------|-------------|
| `PSH {Reg}` | Push register onto stack (AC, X, Y, or PC) |
| `POP {Reg}` | Pop from stack into register |
| `IN Reg` | Read input from external device via handshake |
| `OUT Reg` | Write output to external device via handshake |

### Branch Instructions

| Mnemonic | Condition | Description |
|----------|-----------|-------------|
| `BEQ Addr` | Z = 1 | Branch if equal |
| `BNE Addr` | Z = 0 | Branch if not equal |
| `BGT Addr` | Z = 0, N = V | Branch if greater than |
| `BLT Addr` | N ≠ V | Branch if less than |
| `BGE Addr` | N = V | Branch if greater or equal |
| `BLE Addr` | Z = 1 or N ≠ V | Branch if less or equal |
| `BRA Addr` | — | Branch always (unconditional) |
| `JMP Addr` | — | Jump: push PC+1, then branch (subroutine call) |
| `RET` | — | Return: pop PC from stack |

### ALU Instructions (Register / Immediate)

| Mnemonic | Operation |
|----------|-----------|
| `ADD Reg/Imm` | `AC = AC + operand` |
| `SUB Reg/Imm` | `AC = AC - operand` |
| `MUL Reg/Imm` | `AC = AC × operand` |
| `DIV Reg/Imm` | `AC = AC ÷ operand` |
| `MOD Reg/Imm` | `AC = AC % operand` |
| `AND Reg/Imm` | `AC = AC & operand` |
| `OR Reg/Imm` | `AC = AC \| operand` |
| `XOR Reg/Imm` | `AC = AC ^ operand` |
| `NOT Reg/Imm` | `AC = ~operand` |

> All ALU operations also have **memory-addressed variants** (e.g., `ADD #Addr` → `AC = AC + Mem[Addr]`).

### Shift & Rotate Instructions

| Mnemonic | Operation |
|----------|-----------|
| `LSR` | Logical shift right |
| `LSL` | Logical shift left |
| `RSR` | Rotate right |
| `RSL` | Rotate left |

### Compare, Test & Move

| Mnemonic | Operation |
|----------|-----------|
| `CMP Op1, Op2` | Subtract and set flags (result discarded) |
| `TST Op1, Op2` | AND and set flags (result discarded) |
| `MOV Dest, Src` | Register-to-register move |
| `MOV Reg, #Imm` | Load immediate into register |

### ASIP Tensor Instructions

| Mnemonic | Operation |
|----------|-----------|
| `ADDM` | Tensor addition — adds two memory-resident matrices element-wise |
| `SUBM` | Tensor subtraction — subtracts two memory-resident matrices |
| `ELMULM` | Element-wise tensor multiplication |
| `MULM` | **Full matrix multiplication** — computes C = A × B entirely in hardware |

---

## ASIP: Hardware Matrix Multiplication

The most ambitious part of this processor is the ASIP extension — and within it, the `MULM` instruction.

Where standard processors would need nested loops, explicit index management, and dozens of instructions to multiply two matrices, ASIP16 does it in a **single instruction**. The CPU Control Unit takes over, orchestrating a multi-step sequence that:

1. Reads matrix dimensions from the instruction encoding
2. Iterates over rows of A and columns of B
3. Computes dot products by fetching elements from memory, multiplying via the ALU, and accumulating results
4. Writes the result matrix back to memory
5. Outputs each element through the I/O unit

The `MULM` instruction alone accounts for roughly **one-third of all ASIP control states** — a reflection of the genuine complexity of implementing matrix multiplication as a hardware-sequenced operation rather than a software loop.

```
Example: A(2×3) × B(3×2) = C(2×2)

A = | 1  2  3 |    B = | 1  2 |    C = | 22  28 |
    | 4  5  6 |        | 3  4 |        | 49  64 |
                       | 5  6 |
```

All tensor operations (`ADDM`, `SUBM`, `ELMULM`, `MULM`) support configurable matrix dimensions (2×3, 1×3, 3×3, 2×2) and operate directly on memory-resident data — no register bottleneck.

---

## How an Instruction Executes

To illustrate how the processor works at the signal level, here's what happens when `ADD X` executes — the accumulator adds the value in register X:

```mermaid
sequenceDiagram
    participant CU as Control Unit
    participant PC as Program Counter
    participant MEM as Memory
    participant IR as Instruction Register
    participant ALU as ALU
    participant AC as Accumulator

    Note over CU: S0 - S1: Initialize
    CU->>PC: Load start address
    CU->>PC: AR = PC

    Note over CU: S2: Fetch
    CU->>MEM: Read Mem[AR]
    MEM-->>IR: Instruction word to IR
    CU->>PC: PC = PC + 1

    Note over CU: S3: Decode
    CU->>CU: Decode opcode from IR[15:10]
    Note over CU: opcode = 010100 = ADD_R

    Note over CU: S46: Execute
    CU->>ALU: Start ALU, selector = ADD
    ALU->>ALU: A = 0, Q = AC, M = X
    ALU->>ALU: A = A + M via RCA
    ALU-->>AC: Result to AC
    ALU-->>CU: FLAGS updated N, Z, C, V
    ALU-->>CU: finish signal

    Note over CU: Return to S2, next fetch
```

Every instruction follows this **fetch → decode → execute** pattern, with the Control Unit advancing through its one-hot FSM states and asserting the appropriate control signals at each step.

---

## Prerequisites

### Required

- **[Icarus Verilog](http://iverilog.icarus.com/)** — open-source Verilog simulator

```bash
# Debian / Ubuntu
sudo apt install iverilog

# Arch Linux
sudo pacman -S iverilog

# macOS (Homebrew)
brew install icarus-verilog
```

### Optional

- **[GTKWave](http://gtkwave.sourceforge.net/)** — waveform viewer for `.vcd` files

```bash
# Debian / Ubuntu
sudo apt install gtkwave

# macOS (Homebrew)
brew install --cask gtkwave
```

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/LNM31/ASIP16-Processor.git
cd ASIP16-Processor
```

### 2. Make the run script executable

```bash
chmod +x run.sh
```

### 3. Run a program

**Interactive mode** — select from available programs:

```bash
./run.sh
```

```
Available programs:

  1) program.hex
  2) program_asip_add.hex
  3) program_asip_elmul.hex
  4) program_asip_mul.hex
  5) program_asip_sub.hex

Select program (1-5):
```

**Direct mode** — specify the program:

```bash
./run.sh program                 # General-purpose program
./run.sh program_asip_mul 1      # Matrix multiplication (2×3 matrices)
```

ASIP programs prompt for matrix dimensions:
- `1` → 2×3
- `2` → 1×3
- `3` → 3×3
- `4` → 2×2

### Providing Input During Simulation

The processor reads input through the I/O handshake protocol during execution. **For ASIP programs** (`program_asip_*.hex`), the input sequence is:

1. Enter the number of **rows** (N)
2. Enter the number of **columns** (M)
3. Enter the matrix elements **one by one** (row by row, for each matrix)

For `program_asip_mul` (matrix multiplication), you input both matrices sequentially — first all elements of matrix A, then all elements of matrix B.

> **For non-ASIP programs** (e.g., `program.hex`), refer to the comments inside the `.hex` file — they describe the expected input sequence for each specific program.

### 4. View waveforms (optional)

```bash
gtkwave SoC/soc_tb2.vcd
```

---

## Project Structure

```
ASIP16-Processor/
│
├── SoC/                                # System-on-Chip (top level)
│   ├── SoC.v                           # SoC module — integrates CPU, Memory, I/O
│   ├── SoC_tb2.v                       # Main testbench with verification tasks
│   └── Helpful/                        # Reference documentation
│       ├── instructions_format.txt     # Full ISA specification
│       └── VERILOG_TASKS_DOCUMENTATION.md
│
├── Processor/
│   ├── CPU/
│   │   └── CPU.v                       # Top-level CPU — wires everything together
│   │
│   ├── Control-Unit/
│   │   ├── Control_Unit_CPU.v          # 174-state one-hot FSM (123 control signals)
│   │   └── ffd_OneHot.v                # D flip-flop primitive for one-hot encoding
│   │
│   ├── ALU16/                          # Self-contained ALU subsystem
│   │   ├── ALU/
│   │   │   └── ALU.v                   # ALU top-level with internal register file
│   │   ├── Control_Unit/
│   │   │   └── Control_Unit.v          # ALU FSM (5-bit state, 19 control signals)
│   │   ├── Registers/
│   │   │   ├── A.v                     # Accumulator register (17-bit)
│   │   │   ├── Q.v                     # Secondary operand (shift/rotate capable)
│   │   │   ├── M.v                     # Multiplicand/divisor register
│   │   │   └── counter.v               # Iteration counter for multi-cycle ops
│   │   └── Combinational/
│   │       ├── RCA/                    # Ripple-carry adder + full adder cell
│   │       ├── muxes/                  # 2:1, 4:1, 8:1, 16:1 multiplexers
│   │       ├── comparator/             # 4-bit magnitude comparator
│   │       └── encoder/                # Priority encoder
│   │
│   ├── Registers/
│   │   ├── PC.v                        # Program Counter (with RCA increment)
│   │   ├── SP.v                        # Stack Pointer (inc/dec/load)
│   │   ├── IR.v                        # Instruction Register
│   │   ├── AC.v                        # Accumulator
│   │   ├── AR.v                        # Address Register
│   │   ├── FLAGS.v                     # Status flags: N, Z, C, V
│   │   ├── X.v, Y.v                    # General-purpose registers
│   │   └── R2.v – R9.v                 # Extended registers (ASIP operations)
│   │
│   └── SignExtendUnit/
│       ├── SignExtendUnit.v            # Extends 5/8/9-bit immediates to 16-bit
│       └── SEU_Controller.v            # Karnaugh-map-based format selector
│
├── Memory/
│   └── memory_512x16.v                 # 512-word unified memory (hex-loadable)
│
├── IO/
│   ├── input_unit.v                    # Handshake input (inp_req / inp_ack)
│   └── output_unit.v                   # Handshake output (out_req / out_ack)
│
├── Programs/                           # Pre-assembled programs (hex)
│   ├── program.hex                     # General-purpose test (min/max of array)
│   ├── program_asip_add.hex            # Tensor addition
│   ├── program_asip_sub.hex            # Tensor subtraction
│   ├── program_asip_elmul.hex          # Element-wise multiplication
│   └── program_asip_mul.hex            # Matrix multiplication (MULM)
│
├── run.sh                              # Build & run script (Icarus Verilog)
├── files_relative.txt                  # Source file list for iverilog
└── README.md
```

---

## Design Highlights

### Fully Structural Control Logic
The CPU Control Unit doesn't use a single `case` statement or behavioral `if-else` for generating control signals. Every one of the 123 signals is derived from Boolean equations over the active one-hot state bits and input conditions — the way hardware actually works.

### ALU as a Self-Contained Subsystem
The ALU isn't just a combinational block — it has its own FSM Control Unit, its own internal registers (A, Q, M), and its own handshake protocol with the CPU. Multi-cycle operations like multiplication use Booth's algorithm with iterative add-shift sequences, coordinated entirely by the ALU's local control.

### Hardware Matrix Multiplication
The `MULM` instruction implements full matrix multiplication in hardware. The CPU control unit sequences all nested iterations, memory accesses, ALU invocations, and result writebacks — what would be a triple-nested loop in software becomes a single instruction executing across dozens of FSM states.

### Honest Complexity
174 FSM states. 123 control signals. No abstractions hiding the work. Every state transition, every mux select line, every register enable is explicitly defined. This is the real cost of building a processor from gates up.

---

## Supported Platforms

| Platform | Status |
|----------|--------|
| Linux | Tested |
| macOS | Untested (should work — UNIX-based, Icarus Verilog available via Homebrew) |
| Windows | Not supported |
