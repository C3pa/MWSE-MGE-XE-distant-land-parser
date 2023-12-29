// This module implements conversions between IEEE-754 floating point numbers with 16, 32 and 64 bits of precision.
// For a detailed description of formats see:
// https://github.com/AcademySoftwareFoundation/Imath/blob/main/src/Imath/half.h#L23

// Used to convert texCoords read from MGE XE distant land files.
// The original uses OpenEXR's (Imath) float -> half conversion rutine:
// https://github.com/Hrnchamd/MGE-XE/blob/345ed72c115bc2a1984c649ebe615df81ae04f10/MGEfuncs/NifConverter.cpp#L47

/*
 * This code snippet was posted by user ProjectPhysX on:
 * https://stackoverflow.com/a/60047308
 *
 * Some constants were extracted as const variables.
 * The original code and additional modification are available under the CC BY-SA 4.0:
 * https://creativecommons.org/licenses/by-sa/4.0/
 */


typedef unsigned short ushort;
typedef unsigned int uint;

const uint half_sign_mask = 0x8000;
const uint half_exponent_mask = 0x7C00; // Also: inf
const uint half_mantissa_mask = 0x03FF;
const uint half_sign_bit = 16;
const uint half_mantissa_bits = 10;
const uint half_exponent_bias = 15;
const uint half_qnan = 0x7FFF; // All the bits in the exponent and mantissa are 1s

const uint float_sign_mask = 0x80000000;
const uint float_exponent_mask = 0x7F800000; // Also: inf
const uint float_mantissa_mask = 0x007FFFFF;
const uint float_sign_bit = 32;
const uint float_mantissa_bits = 23;
const uint float_exponent_bias = 127;

const uint mantissa_bits_shift = float_mantissa_bits - half_mantissa_bits;
const uint sign_bit_shift = float_sign_bit - half_sign_bit;
const uint bias_difference = float_exponent_bias - half_exponent_bias;


uint as_uint(const float x) {
	return *(uint*)&x;
}

float as_float(const uint x) {
	return *(float*)&x;
}

float half_to_float(const ushort x) {
	const uint e = (x & half_exponent_mask) >> half_mantissa_bits; // exponent
	const uint m = (x & half_mantissa_mask) << mantissa_bits_shift; // mantissa
	const uint v = as_uint((float)m) >> float_mantissa_bits; // Cast to float is an evil log2 bit hack to count leading zeros in denormalized format
	return as_float(
		(x & half_sign_mask) << sign_bit_shift |
		(e != 0) * ((e + bias_difference) << float_mantissa_bits | m) |
		((e == 0) & (m != 0)) * ((v - 37) << float_mantissa_bits | ((m << (150 - v)) & 0x007FE000))
	); // sign : normalized : denormalized
}

ushort float_to_half(const float x) {
	const uint b = as_uint(x) + 0x00001000; // round-to-nearest-even: add last bit after truncated mantissa
	const uint e = (b & float_exponent_mask) >> float_mantissa_bits; // exponent
	const uint m = b & float_mantissa_mask; // mantissa
	return (b & float_sign_mask) >> sign_bit_shift |
		// The final bit-masking of the exponent ensures that there is no overflow into the sign bit.
		(e > bias_difference) * ((((e - bias_difference) << half_mantissa_bits) & half_exponent_mask) | m >> mantissa_bits_shift) |
		// in line below: 0x007FF000 = 0x00800000-0x00001000 = decimal indicator flag - initial rounding
		((e < 113) & (e > 101)) * ((((0x007FF000 + m) >> (125 - e)) + 1) >> 1) |
		(e > 143) * half_qnan; // sign : normalized : denormalized : saturate
}

// Half-double conversions were also suggested by ProjectPhysX at:
// https://stackoverflow.com/questions/68503093/convert-ieee754-half-precision-bytes-to-double-and-vise-versa-in-flutter
// IEEE-754 16-bit floating-point format (without infinity):
// 1-5-10, exp-15, +-131008.0, +-6.1035156E-5, +-5.9604645E-8, 3.311 digits

double half_to_double(const ushort x) {
	return (double)half_to_float(x);
}

ushort double_to_half(const double x) {
	return float_to_half((float)x);
}
