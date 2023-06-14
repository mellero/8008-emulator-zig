// Register addresses
const IDX_A = (0x00);
const IDX_B = (0x01);
const IDX_C = (0x02);
const IDX_D = (0x03);
const IDX_E = (0x04);
const IDX_H = (0x05);
const IDX_L = (0x06);

// States
const T1      = (0b010);
const T1B     = (0b011);
const T2      = (0b001);
const WAIT    = (0b000);
const T3      = (0b100);
const STOPPED = (0b110);
const T4      = (0b111);
const T5      = (0b101);
const HALT    = (0b00000000);

// Flags
const FLAG_BIT_C = (0x01);
const FLAG_BIT_P = (0x02);
const FLAG_BIT_Z = (0x04);
const FLAG_BIT_S = (0x08);
const FLAG_BITS_ALL = (0x0F);
const FLAG_BITS_NONE = (0x00);

// Stack addresses
const STCK_AS0 = (0x00);
const STCK_AS1 = (0x01);
const STCK_AS2 = (0x02);
const STCK_AS3 = (0x03);
const STCK_AS4 = (0x04);
const STCK_AS5 = (0x05);
const STCK_AS6 = (0x06);
const STCK_AS7 = (0x07);
