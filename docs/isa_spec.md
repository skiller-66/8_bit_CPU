# 8-bit CPU — Instruction Set Architecture (v1)

## Instruction format (8 bits total)

```
Bit:     7        6  5  4       3  2       1  0
Field:  [class] [   opcode   ] [   rd   ] [  rs  ]
```

- **class (1 bit)**: 0 = ALU operation, 1 = memory/control operation
- **opcode (3 bits)**: which specific operation within that class
- **rd (2 bits)**: register 0-3, usually destination
- **rs (2 bits)**: register 0-3, usually second source

## Class 0 — ALU operations
`reg[rd] = ALU_OP(reg[rd], reg[rs])` — result written back into rd.
Opcode encoding matches the ALU module's opcode input exactly (Phase 3).

| opcode | Mnemonic | Operation |
|---|---|---|
| 000 | ADD | reg[rd] = reg[rd] + reg[rs] |
| 001 | SUB | reg[rd] = reg[rd] - reg[rs] |
| 010 | AND | reg[rd] = reg[rd] & reg[rs] |
| 011 | OR  | reg[rd] = reg[rd] \| reg[rs] |
| 100 | XOR | reg[rd] = reg[rd] ^ reg[rs] |
| 101 | NOT | reg[rd] = ~reg[rd]  (rs unused) |
| 110 | SHL | reg[rd] = reg[rd] << 1  (rs unused) |
| 111 | SHR | reg[rd] = reg[rd] >> 1  (rs unused) |

## Class 1 — Memory / control operations

| opcode | Mnemonic | Operation |
|---|---|---|
| 000 | LOAD  | reg[rd] = MEM[reg[rs]] |
| 001 | STORE | MEM[reg[rs]] = reg[rd] |
| 010 | JMP   | PC = reg[rd] |
| 011 | JZ    | if (ALU zero flag set) PC = reg[rd] |
| 100 | HALT  | stop execution |
| 101-111 | (reserved) | unused in v1 |

## Addressing mode
**Register-indirect only.** LOAD/STORE/JMP/JZ never carry a raw address in
the instruction itself — the address always comes from whatever value is
currently sitting in the named register. There is no immediate-load
instruction (MOVI/LDI) in v1; registers that need to hold an address must
be pre-seeded with a starting value before program execution begins
(done via testbench in simulation, equivalent to a hardware reset vector).

## Known v1 limitations (flagged honestly, not fixed yet)
- No way to load an arbitrary constant into a register mid-program
  (no MOVI/LDI). Planned as a v2 upgrade — likely as a variable-length
  instruction, or a reduced-width immediate fit into leftover bits.
- Only 4 registers, only 256 bytes of addressable memory (8-bit address).
- Only 13 usable instructions (opcodes 101-111 in class 1 reserved for
  future use).