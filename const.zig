// Register addresses
pub const IDX_A = (0x00);
pub const IDX_B = (0x01);
pub const IDX_C = (0x02);
pub const IDX_D = (0x03);
pub const IDX_E = (0x04);
pub const IDX_H = (0x05);
pub const IDX_L = (0x06);

// States
pub const T1 = (0b010);
pub const T1B = (0b011);
pub const T2 = (0b001);
pub const WAIT = (0b000);
pub const T3 = (0b100);
pub const STOPPED = (0b110);
pub const T4 = (0b111);
pub const T5 = (0b101);
pub const HALT = (0b00000000);

// Flags
pub const FLAG_BIT_C = (0x01);
pub const FLAG_BIT_P = (0x02);
pub const FLAG_BIT_Z = (0x04);
pub const FLAG_BIT_S = (0x08);
pub const FLAG_BITS_ALL = (0x0F);
pub const FLAG_BITS_NONE = (0x00);

// Stack addresses
pub const STCK_AS0 = (0x00);
pub const STCK_AS1 = (0x01);
pub const STCK_AS2 = (0x02);
pub const STCK_AS3 = (0x03);
pub const STCK_AS4 = (0x04);
pub const STCK_AS5 = (0x05);
pub const STCK_AS6 = (0x06);
pub const STCK_AS7 = (0x07);
