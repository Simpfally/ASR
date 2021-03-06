#include "processor.h"
using namespace std;

//// src_etudiants/simu.rc/processor.cpp

Processor::Processor(Memory* m): m(m) {
	pc=0;
	sp=0;
	a1=0;
	a2=0;
	for (int i=0; i<7; i++)
		r[i]=0;
	for (int i=0; i<140; i++)
		stat_instruc[i]=0;
	nb_ins = 0;
	nb_mem_acc = 0;
}

Processor::~Processor()
{}

int vflag_add(uword a, uword b) {
	sword x = (sword) a;
	sword y = (sword) b;
	return ((x^y) >= 0) && ((x ^ (x +y)) < 0);
}
int vflag_sub(uword a, uword b) {
	sword x = (sword) a;
	sword y = (sword) b;
	int s =!( x > 0 && y > 0 || x < 0 && y < 0);
	if (s) {
		if ((x < 0 && (x-y) > 0) || (x > 0 && (x-y) < 0)) {
			return 1;
		}
	}
	return 0;
}

int Processor::von_Neuman_step(bool debug) {
	// numbers read from the binary code
	int opcode=0;
	int b = 1; // continue?
	int regnum1=0;
	int regnum2=0;
	int regnum3=0;
	int shiftval=0;
	int condcode=0;
	int counter=0;
	int size=0;
	uword offset; 
	uint64_t constop=0; 
	int dir=0;
	// each instruction will use some of the following variables:
	// all unsigned, to be cast to signed when required.
	uword uop1;
	uword uop2;
	uword uop3;
	uword ur=0;
	doubleword fullr;
	bool manage_flags=false; // used to factor out the flag management code
	int instr_pc = pc; // for the debug output
	nb_ins++;
	
	// read 4 bits.
	read_bit_from_pc(opcode);
	read_bit_from_pc(opcode);
	read_bit_from_pc(opcode);
	read_bit_from_pc(opcode);

	switch(opcode) {
		

	case 0x0: // add2
		read_reg_from_pc(regnum1);
		read_reg_from_pc(regnum2);
		uop1 = r[regnum1];
		uop2 = r[regnum2];
		fullr = ((doubleword) uop1) + ((doubleword) uop2); // for flags
		ur = uop1 + uop2;
		r[regnum1] = ur;
	vflag = vflag_add(uop1, uop2);
		manage_flags=true;
		break;

	case 0x1: // add2i
		read_reg_from_pc(regnum1);
		read_const_from_pc(constop);
		uop1 = r[regnum1];
		uop2 = constop; 
		fullr = ((doubleword) uop1) + ((doubleword) uop2); // for flags
		ur = uop1 + uop2;
		r[regnum1] = ur;
		manage_flags=true;
	vflag = vflag_add(uop1, uop2);
		break;
	
	case 0x2: // sub2
		read_reg_from_pc(regnum1);
		read_reg_from_pc(regnum2);
		uop1 = r[regnum1];
		uop2 = r[regnum2];
		fullr = ((doubleword) uop1) - ((doubleword) uop2); // for flags
		ur = uop1 - uop2;
		r[regnum1] = ur;
		manage_flags=true;
	vflag = vflag_sub(uop1, uop2);
		break;
		
	case 0x3: // sub2i
		read_reg_from_pc(regnum1);
		read_const_from_pc(constop);
		uop1 = r[regnum1];
		uop2 = constop; 
		fullr = ((doubleword) uop1) - ((doubleword) uop2); // for flags
		ur = uop1 - uop2;
		r[regnum1] = ur;
		manage_flags=true;
	vflag = vflag_sub(uop1, uop2);
		break;
		
			
	case 0x4: // cmp // fonctionne
		read_reg_from_pc(regnum1);
		read_reg_from_pc(regnum2);
		uop1 = r[regnum1];
		uop2 = r[regnum2];
		fullr = ((doubleword) uop1) - ((doubleword) uop2); // for flags
		ur = uop1 - uop2;
		manage_flags=true;				  
	vflag = vflag_sub(uop1, uop2);
		break;
		
	case 0x5: //cmpi 
		read_reg_from_pc(regnum1);
		read_const_signed_from_pc(offset);
		uop1 = r[regnum1];
		uop2 = offset;
		fullr = ((doubleword) uop1) - ((doubleword) uop2); //for flags
		ur = uop1 - uop2;
		manage_flags=true;
	vflag = vflag_sub(uop1, uop2);
		break;
		
	case 0x6: //let// to test
		read_reg_from_pc(regnum1);
		read_reg_from_pc(regnum2);
		uop2 = r[regnum2];
		r[regnum1] = uop2;
		manage_flags = false;
		break;
		
	case 0x7: //leti// to test
		read_reg_from_pc(regnum1);
		read_const_signed_from_pc(offset);
		uop2 = offset;
		r[regnum1] = uop2;
		manage_flags = false;
		break;
		
	case 0xa: // jump
		read_addr_from_pc(offset);
		if (int(offset) == -13) b = 0;
		pc += offset;
		m -> set_counter(PC, (uword)pc);
		manage_flags=false;		
		break;

	case 0xb: // jumpif // ok
		read_cond_from_pc(condcode);
		read_addr_from_pc(offset);
		if (cond_true(condcode)) {
			pc += offset;
			m -> set_counter(PC, (uword)pc);
		}
		manage_flags=false;
		break;
		
	case 0x8: // shift// oh my god
		read_bit_from_pc(dir);
		read_reg_from_pc(regnum1);
		read_shiftval_from_pc(shiftval);
		uop1 = r[regnum1];
		if(dir==1){ // right shift
			if (int(uop1) < 0) {
				ur = -((-int(uop1)) >> shiftval);
				cflag = 0;
			} else {
				ur = uop1 >> shiftval;
				cflag = ( ((uop1 >> (shiftval-1))&1) == 1);
			}
		}
		else{
			cflag = ( ((uop1 << (shiftval-1)) & (1L<<(WORDSIZE-1))) != 0);
			ur = uop1 << shiftval;
		}
		r[regnum1] = ur;
		zflag = (ur==0);
		// no change to nflag
		manage_flags=false;		
		break;
	case 0x9:
		read_bit_from_pc(opcode);
		switch(opcode) {
			// Lecture des poits faible en premier
				case 0b10010: // readze
					read_counter_from_pc(counter);
					read_size_from_pc(size);
					read_reg_from_pc(regnum1);
					nb_mem_acc += size;
					for (int i = 0; i < size; i++) {
							ur = ur + (m->read_bit(counter) << i);
					}
					r[regnum1] = ur;
					break;
				case 0b10011: // readse signed
					read_counter_from_pc(counter);
					read_size_from_pc(size);
					read_reg_from_pc(regnum1);
					ur = 0;
					nb_mem_acc += size;
					fullr = 0; //last bit read
					for (int i = 0; i < size; i++) {
						fullr = m->read_bit(counter);
						ur = ur + (fullr << i);
					}
					if (fullr) { //last bit was 1 : the number was negative
						for (int i = size; i < WORDSIZE; i++) {
							ur = ur + (1<<i);
						}
					}
					r[regnum1] = ur;

				    break;
		}
		break;

	case 0xc: // Instructions à 6 bits 1100*
		// Fallthrough
	case 0xd: // Instructions à 6 bits 1101*
		//read two more bits
		read_bit_from_pc(opcode);
		read_bit_from_pc(opcode);
		switch(opcode) {
		case 0b110000: // or2
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			uop1 = r[regnum1];
			uop2 = r[regnum2];
			fullr = ((doubleword) uop1) | ((doubleword) uop2); // for flags
			ur = uop1 | uop2;
			manage_flags=true;
			break;
			
		case 0b110001: // or2i
			read_reg_from_pc(regnum1);
			read_const_from_pc(constop);
			uop1 = r[regnum1];
			uop2 =constop;
			fullr = ((doubleword) uop1) | ((doubleword) uop2); // for flags
			ur = uop1 | uop2;
			manage_flags = true;
			break;
			
		case 0b110010: // and2
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			uop1 = r[regnum1];
			uop2 = r[regnum2];
			fullr = ((doubleword) uop1) & ((doubleword) uop2); // for flags
			ur = uop1 & uop2;
			manage_flags=true;
			break;
			
		case 0b110011: // and2i 
			read_reg_from_pc(regnum1);
			read_const_from_pc(constop);
			uop1 = r[regnum1];
			uop2 =constop;
			fullr = ((doubleword) uop1) & ((doubleword) uop2); // for flags
			ur = uop1 & uop2;
			manage_flags = true;
			break;
			
		case 0b110100: // write Low bit to high bits
			read_counter_from_pc(counter);
			read_size_from_pc(size);
			read_reg_from_pc(regnum1);
			nb_mem_acc += size;
			fullr = 1;
			for (int ii = 0; ii < size; ii++) {
				m->write_bit(counter, (r[regnum1] & fullr)>>ii);
				fullr = fullr << 1;
			}
			manage_flags=false;		
			break;
		case 0b110101: //call
				read_addr_from_pc(offset);
				r[7] = pc;
				pc = offset;
				m -> set_counter(PC, (uword)pc);
				manage_flags=false;		
		
			break;
		case 0b110110: //setctr
			read_counter_from_pc(counter);
			read_reg_from_pc(regnum1);
			m -> set_counter(counter, r[regnum1]);
			manage_flags=false;		
			break;
		case 0b110111: //getctr
			read_counter_from_pc(counter);
			read_reg_from_pc(regnum1);
			r[regnum1] = m->counter[counter];
			manage_flags=false;		
			break;
		}
		break;
		
	case 0xe: // Instructions à 7 bits
		//Fallthrough
	case 0xf: // Instructions à 7 bits
		//read 3 more bits
		read_bit_from_pc(opcode);
		read_bit_from_pc(opcode);
		read_bit_from_pc(opcode);
		switch(opcode) {
		case 0b1110000: // push
			read_size_from_pc(size);
			read_reg_from_pc(regnum1);
					nb_mem_acc += size;
			if (m->counter[SP] == 0) {
				m->set_counter(SP, 0x10000); // loin du screen, on est bien
			}
			m->set_counter(SP, m->counter[SP] - size);
			fullr = 1;
			for (int ii = 0; ii < size; ii++) {
				m->write_bit(SP, (r[regnum1] & fullr)>>ii);
				fullr = fullr << 1;
			}

			m->set_counter(SP, m->counter[SP] - size);
			manage_flags=false;		
			break;
		case 0b1110001: // return
				pc = r[7];
				m -> set_counter(PC, (uword)pc);
			manage_flags=false;		
			break;
		case 0b1110010: // add3
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			read_reg_from_pc(regnum3);
			uop2 = r[regnum2];
			uop3 = r[regnum3];
			fullr = ((doubleword) uop2) + ((doubleword) uop3); // for flags
			ur = uop2 + uop3;
			r[regnum1] = ur;
			manage_flags  = true;
		vflag = vflag_add(uop2, uop3);
			break;
		case 0b1110011: // add3i
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			read_const_from_pc(constop);
			uop2 = r[regnum2];
			uop3 = constop;
			fullr = ((doubleword) uop2) + ((doubleword) uop3); // for flags
			ur = uop2 + uop3;
			r[regnum1] = ur;
			manage_flags  = true;
		vflag = vflag_add(uop2, uop3);
			break;
		case 0b1110100: // sub3
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			read_reg_from_pc(regnum3);
			uop2 = r[regnum2];
			uop3 = r[regnum3];
			fullr = ((doubleword) uop2) - ((doubleword) uop3); // for flags
			ur = uop2 - uop3;
			r[regnum1] = ur;
			manage_flags  = true;
		vflag = vflag_sub(uop2, uop3);
			break;
		case 0b1110101: // sub3i
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			read_const_from_pc(constop);
			uop2 = r[regnum2];
			uop3 = constop;
			fullr = ((doubleword) uop2) - ((doubleword) uop3); // for flags
			ur = uop2 - uop3;
			r[regnum1] = ur;
			manage_flags  = true;
		vflag = vflag_sub(uop2, uop3);
			break;
		case 0b1110110: // and3
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			read_reg_from_pc(regnum3);
			uop2 = r[regnum2];
			uop3 = r[regnum3];
			fullr = ((doubleword) uop2) & ((doubleword) uop3); // for flags
			ur = uop2 & uop3;
			r[regnum1] = ur;
			manage_flags  = true;
			break;
		case 0b1110111: // and3i
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			read_const_from_pc(constop);
			uop2 = r[regnum2];
			uop3 = constop;
			fullr = ((doubleword) uop2) & ((doubleword) uop3); // for flags
			ur = uop2 & uop3;
			r[regnum1] = ur;
			manage_flags  = true;
			break;
		case 0b1111000: // or3
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			read_reg_from_pc(regnum3);
			uop2 = r[regnum2];
			uop3 = r[regnum3];
			fullr = ((doubleword) uop2) | ((doubleword) uop3); // for flags
			ur = uop2 | uop3;
			r[regnum1] = ur;
			manage_flags  = true;
			break;
		case 0b1111001: // or3i
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			read_const_from_pc(constop);
			uop2 = r[regnum2];
			uop3 = constop;
			fullr = ((doubleword) uop2) | ((doubleword) uop3); // for flags
			ur = uop2 | uop3;
			r[regnum1] = ur;
			manage_flags  = true;
			break;
		case 0b1111010: // xor3
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			read_reg_from_pc(regnum3);
			uop2 = r[regnum2];
			uop3 = r[regnum3];
			fullr = ((doubleword) uop2) ^ ((doubleword) uop3); // for flags
			ur = uop2 ^ uop3;
			r[regnum1] = ur;
			manage_flags  = true;
			break;
		case 0b1111011: // xor3i
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			read_const_from_pc(constop);
			uop2 = r[regnum2];
			uop3 = constop;
			fullr = ((doubleword) uop2) ^ ((doubleword) uop3); // for flags
			ur = uop2 ^ uop3;
			r[regnum1] = ur;
			manage_flags  = true;
			break;
		case 0b1111110: // asr3
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			read_shiftval_from_pc(shiftval);
			uop2 = r[regnum2];
			cflag = ( ((uop2 << (shiftval-1)) & (1L<<(WORDSIZE-1))) != 0);
			ur = uop2 << shiftval;
			r[regnum1] = ur;
			zflag = (ur==0);
			// no change to nflag
			manage_flags=false;		
				break;
			}
		break;
	}
	// STATISTIQUES
	stat_instruc[opcode]++;
	
	// flag management
	if(manage_flags) {
		zflag = (ur==0);
		cflag = (fullr > ((doubleword) 1)<<WORDSIZE);
		nflag = (0 > (sword) ur);

	}


	if (debug) {
		cout << "pc=" << dec << instr_pc << "  r0=" << int(r[0]) <<"  r1=" << r[1] <<"  r2=" << int(r[2]) <<"  r3=" << int(r[3]) <<"  r4=" << int(r[4]) <<"  r5=" << r[5] <<"  r6=" << r[6] <<"  r7=" << r[7] << endl;
		cout << "after instr: " << opcode << " at pc=" << instr_pc << " A0 = " << m->counter[2] << " A1 = " << m->counter[3];  /*<< hex << setw(8) << setfill('0') << instr_pc
				 << " (newpc=" << hex << setw(8) << setfill('0') << pc
				 << " mpc=" << hex << setw(8) << setfill('0') << m->counter[0] 
				 << " msp=" << hex << setw(8) << setfill('0') << m->counter[1] 
				 << " ma0=" << hex << setw(8) << setfill('0') << m->counter[2] 
				 << " ma1=" << hex << setw(8) << setfill('0') << m->counter[3] << ") ";
			//				 << " newpc=" << hex << setw(9) << setfill('0') << pc; */
		cout << " zcvn = " << (zflag?1:0) << (cflag?1:0) << (vflag?1:0)  << (nflag?1:0) << endl;
		/*for (int i=0; i<8; i++)
			cout << " r"<< dec << i << "=" << hex << setw(8) << setfill('0') << r[i];
		cout << endl;*/
	}
	return b;
}


// form now on, helper methods. Read and understand...

void Processor::read_bit_from_pc(int& var) {
	var = (var<<1) + m->read_bit(PC); // the read_bit updates the memory's PC
	pc++;							  // this updates the processor's PC
}

void Processor::read_reg_from_pc(int& var) {
	var=0;
	read_bit_from_pc(var);
	read_bit_from_pc(var);
	read_bit_from_pc(var);
}


//unsigned
void Processor::read_const_from_pc(uint64_t& var) {
	var=0;
	int header=0;
	int size;
	read_bit_from_pc(header);
	if(header==0)
		size=1;
	else  {
		read_bit_from_pc(header);
		if(header==2)
			size=8;
		else {
			read_bit_from_pc(header);
			if(header==6)
				size=32;
			else
				size=64;
		}
	}
	// Now we know the size and we can read all the bits of the constant.
	for(int i=0; i<size; i++) {
		var = (var<<1) + m->read_bit(PC);
		pc++;
	}		
}


void Processor::read_const_signed_from_pc(uword& var) {
	var=0;
	int header=0;
	int size;
	var=0;
	read_bit_from_pc(header);
	if(header==0)
		size=1;
	else  {
		read_bit_from_pc(header);
		if(header==2)
			size=8;
		else {
			read_bit_from_pc(header);
			if(header==6)
				size=32;
			else
				size=64;
		}
	}
	// Now we know the size and we can read all the bits of the constant.
	for(int i=0; i<size; i++) {
		var = (var<<1) + m->read_bit(PC);
		pc++;
	}

	// sign extension
	int sign= (var >> (size-1)) & 1;
	if (sign && size != 1) {
		for (int i=size; i<WORDSIZE; i++)
			var += sign << i;
	}

}
// Beware, this one is sign-extended
void Processor::read_addr_from_pc(uword& var) {
	var=0;
	int header=0;
	int size;
	var=0;
	read_bit_from_pc(header);
	if(header==0)
		size=8;
	else  {
		read_bit_from_pc(header);
		if(header==2)
			size=16;
		else {
			read_bit_from_pc(header);
			if(header==6)
				size=32;
			else
				size=64;
		}
	}
	// Now we know the size and we can read all the bits of the constant.
	for(int i=0; i<size; i++) {
		var = (var<<1) + m->read_bit(PC);
		pc++;
	}
	// cerr << "before signext " << var << endl;
	// sign extension
	int sign=(var >> (size-1)) & 1;
	for (int i=size; i<WORDSIZE; i++)
		var += sign << i;
	// cerr << "after signext " << var << " " << (int)var << endl;

}




void Processor::read_shiftval_from_pc(int& var) {
	var = 0;
	read_bit_from_pc(var);
	if (var == 0) {
		for (int i=0; i<6; i++)
			read_bit_from_pc(var);
	}
}

void Processor::read_cond_from_pc(int& var) {
	var =0;
	read_bit_from_pc(var);
	read_bit_from_pc(var);
	read_bit_from_pc(var);
}


bool Processor::cond_true(int cond) { // Fonctionne ok
	switch(cond) {
	case 0 : // EQ
		return (zflag);
		break;
	case 1 : // NOT EQ
		return (!zflag);
		break;
	case 2 : // signed greater than >
		return !zflag && ((nflag && vflag) || (!nflag && !vflag));
		break;
	case 3 : // signed smaller than <
		return ((nflag && !vflag) || (!nflag && vflag) )&& !zflag;
		break;
	case 4 : // unsigned GT >
		return (!cflag && !zflag);
		break;
	case 5 : // unsigned GE >=
		return (!cflag);
		break;
	case 6 : // unsigned LT <
		return (cflag);
		break;
	case 7 : // two's complement overflow
		return vflag;
		break;
		
	}
	throw "Unexpected condition code";
}


void Processor::read_counter_from_pc(int& var) {
	var =0;
	read_bit_from_pc(var);
	read_bit_from_pc(var);
}


void Processor::read_size_from_pc(int& size) {
	size =0;
	int header =0;
	read_bit_from_pc(header);
	read_bit_from_pc(header);
	if (header == 0) {
			size = 1;
	} else if (header == 1) {
			size = 4;
	} else {
			read_bit_from_pc(header);
			if (header == 4)
					size = 8;
			if (header == 5)
					size = 16;
			if (header == 6)
					size = 32;
			if (header == 7)
					size = 64;
	}
}
