# Little Man Computer
The [Little Man Computer ](https://en.wikipedia.org/wiki/Little_man_computer)(LMC) is a very simply microprocessor and computer system designed for teaching beginners assembly programming. To make things simpler it is not presented as a binary computer but a decimal one. It contains 100 memory cells, numbered from 0-99. You can place program instructions and data here.

Each cell can hold a 3-digit decimal number. Here we can store instructions for the computer to perform or data to operate on. The CPU has a single accumulator which is used when performing arithmetic. There is also an input and ouput where you can read user input and write outputs to the user.

Here is a simple overview of the instructionset. Each instruction is really just a 3-digit number. But usually when programming one deals with letter abbreviations which are easier to remember. Here is a tip on how to read the description below. E.g. the `Add` instruction is described as having the number `1xx`. What this really means is that the `xx` are where you put your operand (argument). So `142` is the instruction for adding the contents of memory cell 42 to the contents of the accumulator.

- `ADD` 1xx add content at address `xx` in memory to accumulator.
- `SUB` 2xx subtract contents of address `xx` from what is stored in the accumulator. Store result in accumulator.
- `STA` 3xx store accumulator at address `xx` in memory.
- `LDA` 5xx load accumulator with contents at address `xx` in memory.
- `BRA` 6xx jump to location `xx` in program.
- `BRZ` 7xx jump if accumulator is zero
- `BRP` 8xx jump if accumulator is zero or higher (positive).
- `INP` 901 fill accumulator with number from input.
- `OUT` 902 push value in accumulator into output queue.
- `HLT` 000 stop program

## Example of LMC Programs
In the example folder you can find more examples of programs. Here is an example of a program which reads a number from the input and then counts down. So if it reads a 4 on input, then it will write out 4, 3, 2, 1 and 0 on the output.

         INP
         OUT
    LOOP BRZ QUIT // Jump to QUIT if accumulator is 0
         SUB ONE  // Subtract from accumulator what is stored in ONE
         OUT
         BRA LOOP // Jump (unconditionally) to the memory address labeled LOOP
    QUIT HLT      // Label this memory address as QUIT
    ONE  DAT 1    // Store 1 in this memory address.
    
## How to Use Julia Package
You can take a program written as the example store it in a file and give that filename to the `assemble(file)` function which will produce a list of 3-digit integers representing your program and data. You can feed this to the `execute(program, inputs)` function to run your program. It will dump output.

Alternatively you can copy paste this and put the code into one of the web based LMC simulators described below.


## LMC Simulators on the Web
You can  find several browser based simulators for the LMC CPU online. Where you can step through programs and watch live how the virtual computer operates.

- [101 Computing Simulator](https://www.101computing.net/LMC/). Looks fancy in terms of appearance.
- [Robo Writer Simulator](http://robowriter.info/little-man-computer/). More plain and primitive looking, but I actually prefer this version.

## LMC Based Games
There are several games you can play based on slight variations of the LMC idea. This is potentially a nice way of getting children involved in learning programming.

- [Human Resource Machine](https://tomorrowcorporation.com/humanresourcemachine)
- [TIS-100](http://www.zachtronics.com/tis-100/) a game by Zachtronics where you basically deal with multiple LMC computers which you got to program to communicate with each other.
- [Shenzhen IO](http://www.zachtronics.com/shenzhen-io/) also by Zachtronics where you program small electronic gizmos that communicate with each other. Very similar to LMC but with the element of timing, which matters a lot in electronics.
