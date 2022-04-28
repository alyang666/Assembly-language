# IEEE754 X Assembly-language

https://en.wikipedia.org/wiki/IEEE_754

IEEE754 : 
An IEEE 754 format is a "set of representations of numerical values and symbols". A format may also include how the set is encoded.[9]

A floating-point format is specified by

a base (also called radix) b, which is either 2 (binary) or 10 (decimal) in IEEE 754;
a precision p;
an exponent range from emin to emax, with emin = 1 − emax for all IEEE 754 formats;



A format comprises

Finite numbers, which can be described by three integers: s = a sign (zero or one), 
  c = a significand (or coefficient) having no more than p digits when written in base b (i.e., an integer in the range through 0 to bp − 1), 
  and q = an exponent such that emin ≤ q + p − 1 ≤ emax. 
  The numerical value of such a finite number is (−1)s × c × bq.[a] Moreover, there are two zero values, 
  called signed zeros: the sign bit specifies whether a zero is +0 (positive zero) or −0 (negative zero);
Two infinities: +∞ and −∞;
Two kinds of NaN (not-a-number): a quiet NaN (qNaN) and a signaling NaN (sNaN);



For example, if b = 10, p = 7, and emax = 96, then emin = −95, the significand satisfies 0 ≤ c ≤ 9999999, and the exponent satisfies −101 ≤ q ≤ 90. Consequently, the smallest non-zero positive number that can be represented is 1×10−101, and the largest is 9999999×1090 (9.999999×1096), so the full range of numbers is −9.999999×1096 through 9.999999×1096. The numbers −b1−emax and b1−emax (here, −1×10−95 and 1×10−95) are the smallest (in magnitude) normal numbers; non-zero numbers between these smallest numbers are called subnormal numbers.


