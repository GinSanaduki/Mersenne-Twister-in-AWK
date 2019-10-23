# mersenne_twister.awk
# 2019.10.23

# Mersenne Twister in AWK(GAWK) based on "mt19937ar.c", "mt.js", "mersenne-twister.js".
# AWK(GAWK) version by GinSanaduki.
# Copyright (C) 2019 GinSanaduki.

# Original C version by Makoto Matsumoto and Takuji Nishimura
# http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/mt.html
# Ported in JavaScript version by Magicant
# https://magicant.github.io/sjavascript/mt.html
# Ported in JavaScript version by Sean McCullough
# https://gist.github.com/banksean/300494

# ----------------------------------------------------------------------------------------------

# Copyright (C) 1997 - 2002, Makoto Matsumoto and Takuji Nishimura,
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
	# 1. Redistributions of source code must retain the above copyright
	# notice, this list of conditions and the following disclaimer.
	
	# 2. Redistributions in binary form must reproduce the above copyright
	# notice, this list of conditions and the following disclaimer in the
	# documentation and/or other materials provided with the distribution.

	# 3. The names of its contributors may not be used to endorse or promote 
	# products derived from this software without specific prior written 
	# permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Any feedback is very welcome.
# http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/emt.html
# email: m-mat @ math.sci.hiroshima-u.ac.jp (remove space)

# ----------------------------------------------------------------------------------------------

BEGIN{
	varInit();
	checkArgs();
	init_genrand(Seed);
	if(Mode == "next"){
		print random();
	} else {
		print opsNextInt();
	}
}

# ----------------------------------------------------------------------------------------------

function varInit(){
	N = 624;
	M = 397;
	ZERO = strtonum(0x00000000);
	ONE = strtonum(0x00000001);
	# constant vector a.
	MATRIX_A = strtonum(0x9908B0DF);
	# most significant w-r bits.
	UPPER_MASK = strtonum(0x80000000);
	# least significant r bits.
	LOWER_MASK = strtonum(0x7FFFFFFF);
	# "mti == N+1" means mt[N] is not initialized.
	mti = N + 1;
	DecPointMax = 15;
	# 2^32
	# 0x100000000 : 4294967296
	2Power32 = strtonum(0x100000000);
}

# ----------------------------------------------------------------------------------------------

function checkArgs(){
	# Check "Mode" in the argument.
	if(Mode != "next" && Mode != "nextInt"){
		print "Invalid Argument. : Mode";
		exit 99;
	}
	# Check "OSBit" in the argument.
	# If "64" is not specified in the argument, it is assumed to be specified "32".
	if(OSBit != 64){
		OSBit = 32;
	}
	# Check "Seed" in the argument.
	# If "Seed" does not exist in the argument, is not a number, or 0, the unix time is set.
	# In awk, it is used that it is treated as 0 when performing arithmetic evaluation 
	# with a character string that cannot be evaluated.
	Seed = Seed + 0;
	if(Seed == 0){
		Seed = systime();
	}
	# Round down after the decimal point.
	Seed = int(Seed);
	if(Mode == "nextInt"){
		# Check "Sup" and "Min" in the argument.
		# If "Min" does not exist in the argument, 0 is assigned.
		Min = Min + 0;
		Sup = Sup + 0;
		if(Sup == Min && Sup > 0){
			print "Sup and Min are the same value or 0. : checkArgs";
			exit 99;
		}
		if(Sup == Min && Sup == 0){
			Sup = 2Power32 - 1;
		}
		if(Sup < Min){
			Temp = Sup;
			Sup = Min;
			Min = Temp;
			Temp = "";
		}
	}
	if(Mode == "next"){
		# Specifies the display of the number of digits after the decimal point for random numbers.
		# In the awk specification, if nothing is specified, an output with more than 7 digits 
		# including the decimal point will be displayed in exponential notation.
		# Therefore, it must be specified in the built-in variable “OFMT”.
		DecPoint = DecPoint + 0;
		# The maximum number of significant figures when calculating AWK numbers is 
		# about 15 when compiled for a 32-bit OS.
		# It doesn't make much sense to display longer than that.
		# Therefore, when 16 or more is specified, 15 is reset.
		# If you still need more than 16 digits, change "DecPointMax".
		if(DecPoint >= DecPointMax + 1){
			DecPoint = DecPointMax;
		}
		# If nothing is specified, the output will be in 6-digit floating point notation.
		# Values with more than 6 decimal places are rounded off.
		if(DecPoint == 0){
			DecPoint = 6;
		}
		OFMT="%."DecPoint"f";
		if(OSBit == 32){
			# Check "SubMode" in the argument.
			# If anything other than "int31", "real1", or "real3" is specified as an argument, 
			# or if no argument is specified, it is assumed that int32 has been specified.
			if(SubMode != "int31" && SubMode != "real1" && SubMode != "real3"){
				SubMode = "int32";
			}
		}
	}
}

# ----------------------------------------------------------------------------------------------
# initializes mt[N] with a seed
function init_genrand(s){
	mt[0] = rshift(s,0);
	for (mti=1; mti < N; mti++) {
		spadework_01_rs30 = rshift(mt[mti - 1],30);
		s = xor(mt[mti - 1],spadework_01_rs30);
		spadework_02_AND = and(s,0xFFFF0000);
		spadework_03_rs16 = rshift(spadework_02_AND,16);
		spadework_04_Multiply = spadework_03_rs16 * 1812433253;
		spadework_05_rs16 = rshift(spadework_04_Multiply,16);
		spadework_06_AND = and(s,0x0000FFFF);
		spadework_07_Multiply = spadework_06_AND * 1812433253;
		mt[mti] = spadework_05_rs16 + spadework_07_Multiply + mti;
		# See Knuth TAOCP Vol2. 3rd Ed. P.106 for multiplier.
		# In the previous versions, MSBs of the seed affect only MSBs of the array mt[].
		# 2002/01/09 modified by Makoto Matsumoto
		mt[mti] = rshift(mt[mti],0);
		# for >32 bit machines
	}
}

# ----------------------------------------------------------------------------------------------

function random(){
	if(OSBit == 32){
		retVal = genrand_int32();
		if(SubMode == "int32"){
			# generates a random number on [0,1)-real-interval
			# divided by 2^32
			return retVal / 2Power32;
		} else if(SubMode == "int31"){
			# generates a random number on [0,0x7fffffff]-interval
			return rshift(retVal,1);
		} else if(SubMode == "real1"){
			# generates a random number on [0,1]-real-interval
			# divided by 2^32-1
			F8 = 2Power32 - 1;
			return retVal / F8;
		} else {
			# generates a random number on (0,1)-real-interval
			retVal = retVal + 0.5;
			# divided by 2^32
			return retVal / 2Power32;
		}
	} else {
		# generates a random number on [0,1) with 53-bit resolution
		retVal_01 = genrand_int32();
		retVal_02 = genrand_int32();
		retVal_01_rs5 = rshift(retVal_01,5);
		retVal_02_rs6 = rshift(retVal_02,6);
		# 0x4000000 : 67108864
		retVal_03 = retVal_01_rs5 * strtonum(0x4000000) + retVal_02_rs6;
		# 0x20000000000000 : 9007199254740992
		return retVal_03 / strtonum(0x20000000000000);
	}
}

# ----------------------------------------------------------------------------------------------

# generates a random number on [0,0xffffffff]-interval
function genrand_int32(){
	# mag01[x] = x * MATRIX_A  for x=0,1
	mag01[0] = ZERO;
	mag01[1] = MATRIX_A;
	
	# generate N words at one time
	if (mti >= N) {
		kk = 0;
		#  if init_genrand() has not been called, a default initial seed is used.
		if (mti == N + 1){
			init_genrand(5489);
		}
		for (kk = 0; kk < N - M; kk++) {
			initGenrand_int32();
			spadework_01_AND = and(mt[kk],UPPER_MASK);
			spadework_02_AND = and(mt[kk + 1],LOWER_MASK);
			y = or(spadework_01_AND,spadework_02_AND);
			spadework_03_rs1 = rshift(y,1);
			spadework_04_AND = mag01[and(y,ONE)];
			spadework_05_XOR = xor(mt[M - 1],spadework_03_rs1);
			mt[N - 1] = xor(spadework_05_XOR,spadework_04_AND);
		}
		for (; kk < N-1; kk++) {
			initGenrand_int32();
			spadework_01_AND = and(mt[kk],UPPER_MASK);
			spadework_02_AND = and(mt[kk + 1],LOWER_MASK);
			y = or(spadework_01_AND,spadework_02_AND);
			spadework_03_rs1 = rshift(y,1);
			spadework_04_AND = mag01[and(y,ONE)];
			spadework_05_XOR = xor(mt[kk + M - N],spadework_03_rs1);
			mt[kk] = xor(spadework_05_XOR,spadework_04_AND);
		}
		initGenrand_int32();
		spadework_01_AND = and(mt[N - 1],UPPER_MASK);
		spadework_02_AND = and(mt[0],LOWER_MASK);
		y = or(spadework_01_AND,spadework_02_AND);
		spadework_03_rs1 = rshift(y,1);
		spadework_04_AND = mag01[and(y,ONE)];
		spadework_05_XOR = xor(mt[M - 1],spadework_03_rs1);
		mt[N - 1] = xor(spadework_05_XOR,spadework_04_AND);
		mti = 0;
	}
	y = mt[mti++];
	
	# Tempering
	spadework_01_rs11 = rshift(y,11);
	y = xor(y,spadework_01_rs11);
	spadework_02_rs7 = rshift(y,7);
	spadework_03_AND = and(spadework_02_rs7,0x9D2C5680);
	y = xor(y,spadework_03_AND);
	spadework_04_rs15 = rshift(y,15);
	spadework_05_AND = and(spadework_04_rs15,0xEFC60000);
	y = xor(y,spadework_05_AND);
	spadework_06_rs18 = rshift(y,18);
	y = xor(y,spadework_06_rs18);
	return rshift(y,0);
}

# ----------------------------------------------------------------------------------------------

function initGenrand_int32(){
	spadework_01_AND = 0;
	spadework_02_AND = 0;
	spadework_03_rs1 = 0;
	spadework_04_AND = 0;
	spadework_05_XOR = 0;
	spadework_01_rs11 = 0;
	spadework_02_rs7 = 0;
	spadework_03_AND = 0;
	spadework_04_rs15 = 0;
	spadework_05_AND = 0;
	spadework_06_rs18 = 0;
}

# ----------------------------------------------------------------------------------------------

function opsNextInt(){
	minOpsNextInt = Min;
	supOpsNextInt = Sup - Min;
	if (0 < supOpsNextInt && sup < 2Power32){
		;
	} else {
		retVal = genrand_int32();
		return retVal + minOpsNextInt;
	}
	spadework_01_Oper2 = compl(supOpsNextInt) + 1;
	spadework_02_AND = and(supOpsNextInt,spadework_01_Oper2);
	if(spadework_02_AND == supOpsNextInt){
		spadework_03_Oper1 = supOpsNextInt - 1;
		retVal = genrand_int32();
		spadework_04_AND = and(spadework_03,retVal);
		return retVal + minOpsNextInt;
	}
	do{
		retVal = genrand_int32();
		spadework_05_Quotient = retVal % supOpsNextInt;
		spadework_06 = retVal - spadework_05_Quotient;
		spadework_07 = 2Power32 - spadework_06;
	} while (supOpsNextInt > spadework_07)
	
	return retVal + minOpsNextInt;
}

# These real versions are due to Isaku Wada, 2002/01/09 added.

