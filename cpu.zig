const HALT = @import("const.zig").HALT;
// * * * * * * * * Four basic functional blocks * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// *  * Instruction register
// *      *   Instructions are fetched from memory, stored in the inst. reg. and decoded for control of both the memories and ALU
// *      *   Instruction decoder also controls state transitions
// *  * Memory
// *      *   Two separate dynamic memories are used: pushdown address stack, and a scratch pad
// *      *   These are automatically refreshed by each WAIT, T3, and STOPPED state. Worst case, also every 80 clock periods
// *  * Arithmetic Logic Unit
// *  * I/O Buffers
// *
// * * * * * * * * Processor Timing * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// * State signals S0, S1, and S2, along with SYNC, inform the peripheral circuitry of the state of the processor
// * A table of binary state coedes and designated state name is as follows:
// *
// *      * * * * * * * * * * * * * * * * * * * *
// *      * S0  * * S1  * * S2  * * STATE   * * *     ACK
// *      * * * * * * * * * * * * * * * * * * * *
// *      *  0  * *  1  * *  0  * *  T1       * *
// *      *  0  * *  1  * *  1  * *  T1|      * *     INTERRUPT
// *      *  0  * *  0  * *  1  * *  T2       * *
// *      *  0  * *  0  * *  0  * *  WAIT     * *     READY
// *      *  1  * *  0  * *  0  * *  T3       * *
// *      *  1  * *  1  * *  0  * *  STOPPED  * *     HALT
// *      *  1  * *  1  * *  1  * *  T4       * *
// *      *  1  * *  0  * *  1  * *  T5       * *
// *      * * * * * * * * * * * * * * * * * * * *
// *
// * A cycle typically consists of five states
// *      *   Two states in which an address is sent to memory (T1, T2)
// *      *   One for instruction or data fetch (T3)
// *      *   Two states for execution of instruction (T4, T5)
// * When memories are not available for sending/receiving data, processor goes into WAIT state
// * Receipt of an INTERRUPT is acknowledged by T1|. When the processor has been interrupted, this state replaces T1.
// *      * When 8008 in T1| state, the program counter is not incremented
// * READY is acknowledged by T3
// * STOPPED acknowledges the receipt of HALT
// * Many instructions are mutli-cycle, and don't require T4 and T5. As such, they are omitted when not needed
// *
// **     ** Refer to state transition diagram **     **
// *
// * The first cycle is always an instruction fetch cycle (PCI).
// * The second and third cycles are for data reading (PCR), data writing (PCW), or I/O operations (PCC)
// * The cycle types are coded with two bits: D6 and D7, and are only present on the data bus during T2
// *
// *      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// *      *  D6 * *  D7 * * CYCLE  * *                             FUNCTION                                     * *
// *      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// *      *  0  * *  0  * *  PCI  * *  Designates address is for memory read (first byte of inst.)              * *
// *      *  0  * *  1  * *  PCR  * *  Designates address is for memory read (additional bytes of inst. data)   * *
// *      *  1  * *  0  * *  PCC  * *  Designates data as a command I/O operation                               * *
// *      *  1  * *  1  * *  PCW  * *  Designates address is for a memory write                                 * *
// *      * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// *
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

const STATES = struct {
    S0: u1,
    S1: u1,
    S2: u1,
    // uint8_t SYNC;
};

// * * * * * * * * Condition Flip Flops * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// * These bits provide conditional branching capability through CALL, JUMP, or RETURN on condition instructions.
// * Carry bit provides the ability to do multiple precision binary arithmetic
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

const STACK = struct {
    PC: u14,
    SP: u3,
    AS0: u16,
    AS1: u16,
    AS2: u16,
    AS3: u16,
    AS4: u16,
    AS5: u16,
    AS6: u16,
};

const REG = struct {
    A: u8,
    B: u8,
    C: u8,
    D: u8,
    E: u8,
    H: u8,
    L: u8,
};

const FLAGS = struct {
    C: u1, // Carry
    P: u1, // Even Parity
    Z: u1, // Zero
    S: u1, // Sign
};

pub const CPU = struct {
    inst: u8,

    // * * * * * * * * Address Stack and Program Counter * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    // * Contains eight 14-bit registers, providing storage for eight lower, and six higher order address bits in each register
    // * One is the program counter, seven are address storage for nesting of subroutines up to seven levels
    // *
    // * Stack automatically stores content of PC upon execution of CALL, and automatically resotres the PC upon execution of RETURN
    // *      *   CALLs may be nested, and registers of stack are used as last in/first out pushdown stack
    // *
    // * A 3-bit address pointer is used to designate the present location of the PC
    // * When capacity of stack is exceeded, the address pointer recycles, and content of lowest level register is destroyed
    // * PC is incremented immediately after lower order address bits are sent out
    // * Highest order address bits are sent out at T2, and then incremented if a carry resulted from T1
    // *
    // * PC provides direct addressing of 16K bytes of memory
    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    stack: STACK,

    // * * * * * * * * Acc and Scratch Pad Mem * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    // * All arithmetic operations use the accumulator as one of the operands
    // * In case of instructions which require ops with a register in external memory, scratch pad registers H & L provide indirect addressing
    // *      *   Register L contains eight lower order bits of address
    // *      *   Register H contains six higher order bits of address
    // *      *   Bits 6 and 7 of H are "don't cares"
    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    reg: REG,

    flags: FLAGS,
    // Do I need an ALU?

    // * Data in the 8008 is stored in the form of 8-bit binary integers:
    // * * * * * * * * * * * * * * * * * * * * * * *
    // *         * D7 D6 D5 D4 D3 D2 D1 D0 *
    // * * * * * * * * * Data Word * * * * * * * * *
    // * Instructions are one, two, or three bytes in length

    // * * * * * * * * Processor Control Signals * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    // * * * * Interrupt Signal (INT)  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    // * When enabled, the CPU recognizes an interrupt request at the next instruction fetch (PCI) cycle by outputting
    // *      S0 S1 S2 = 011 at T1| time.
    // * Lower and higher order address bytes of PC are sent out, but PC is NOT advanced
    // *      * If a HALT is inserted, the CPU enteres a STOPPED state
    // *      * If NOP is inserted, the CPU continues
    // *      * If "JUMP to 0" inserted, processor executres program from location 0, etc
    // *      *
    // *
    // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
};

pub fn initCPU() CPU {
    const cpu: CPU = .{
        .inst = HALT,
        .stack = .{
            .PC = 0x00,
            .SP = 0x00,
            .AS0 = 0x00,
            .AS1 = 0x00,
            .AS2 = 0x00,
            .AS3 = 0x00,
            .AS4 = 0x00,
            .AS5 = 0x00,
            .AS6 = 0x00,
        },
        .reg = .{
            .A = 0x00,
            .B = 0x00,
            .C = 0x00,
            .D = 0x00,
            .E = 0x00,
            .H = 0x00,
            .L = 0x00,
        },
        .flags = .{
            .C = 0,
            .P = 0,
            .Z = 0,
            .S = 0,
        },
    };

    return cpu;
}
