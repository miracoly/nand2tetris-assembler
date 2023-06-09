# Hack Assembler - Nand2Tetris

![GitHub Workflow Status (with event)](https://img.shields.io/github/actions/workflow/status/miracoly/nand2tetris-assembler/run-tests.yml?style=for-the-badge&logo=haskell&label=stack%20test&link=https%3A%2F%2Fgithub.com%2Fmiracoly%2Fnand2tetris-assembler%2Factions%2Fworkflows%2Frun-tests.yml)

[Nand2Tetris](https://www.nand2tetris.org/) is a 12-week online course [available at Coursera](https://www.coursera.org/learn/build-a-computer) which teaches the fundamentals of computer architecture and low-level programming.
Week 6 is about programming an assembler for the previous build architecture, called the Hack computer. This is my solution...

## Usage
- Install with `stack install`. This builds executable `nand2tetris-assembler`
- From StdIn: `nand2tetris-assembler` -> enter assembly code (end input with `Ctrl+D`) -> outputs to StdOut
- From File `nand2tetris-assembler path/to/file` -> reads file and writes to `output.hack`

### Additional Infos
- Outputs machine code as Ascii, not bytes. This is needed to work with provided CpuSimulator.
- This project passes all provided tests assembly programs, but it's still far from production ready. Its main purpose was **learning**.
  - Error handling ist minimal.
  - Performance was not considered.
  - CLI is minimal

## Example
Find Max (Example from project 6 - download [software suite](https://www.nand2tetris.org/software))
```
// Computes R2 = max(R0, R1)  (R0,R1,R2 refer to RAM[0],RAM[1],RAM[2])

   @R0
   D=M              // D = first number
   @R1
   D=D-M            // D = first number - second number
   @OUTPUT_FIRST
   D;JGT            // if D>0 (first is greater) goto output_first
   @R1
   D=M              // D = second number
   @OUTPUT_D
   0;JMP            // goto output_d
(OUTPUT_FIRST)
   @R0
   D=M              // D = first number
(OUTPUT_D)
   @R2
   M=D              // M[2] = D (greatest number)
(INFINITE_LOOP)
   @INFINITE_LOOP
   0;JMP            // infinite loop
```

compiles to

```
0000000000000000
1111110000010000
0000000000000001
1111010011010000
0000000000001010
1110001100000001
0000000000000001
1111110000010000
0000000000001100
1110101010000111
0000000000000000
1111110000010000
0000000000000010
1110001100001000
0000000000001110
1110101010000111
```