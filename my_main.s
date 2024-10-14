        PRESERVE8
        AREA MyCode, CODE, READONLY
        EXPORT asmmain

addition EQU 0x2B 
subtraction EQU 0x2D
division EQU 0x2F
multiply EQU 0x2A
equals EQU 0x3D
enter EQU 0x0D
mask EQU 0x0000000F
newline EQU 0x0A

asmmain
SRAM_BASE EQU 0x20000200
		import putChar
		import putCharStr
		import getinput
			
		LDR r7, =toMemory

start
		LDR r9, =0x00
		LDR r10, =0x00
		LDR r0, =startmsg
		BL putCharStr
		
getval	
		BL getinput
		PUSH {r0}
		BL putChar
		POP {r0}
		
		CMP r0, #addition
		BEQ addit

		CMP r0, #subtraction
		BEQ subit
		
		CMP r0, #division
		BEQ.W divit
		
		CMP r0, #multiply
		BEQ mulit
		
		CMP r0, #enter
		BEQ entered
		
		CMP r0, #equals
		BEQ.W equit
		
		CMP r0, #0x29
		BLE rangeerr
		CMP r0, #0x40
		BGE rangeerr
		
		BL hexconvert
	
rangeerr
		LDR r0, =outofrange
		BL putCharStr
		BL start
		
hexconvert
		SUBS r0, #0x30 
		STR r0, [r7], #1
		ADDS r9, #0x01 
		BL getval 
		
entered
		CMP r10, #0x00
		BNE opclear
		
		
		LDR r6, =0x00 
		LDR r4, =0x0A 
		LDR r2, [r7, #-1]! 
		

		ADDS r6, r2 
		SUBS r9, #0x01 
		CMP r9, #0x00 
		BEQ skip 
		

		LDR r2, [r7, #-1]! 
		AND r2, #mask 
		MUL r2, r4 
		ADDS r6, r2
		SUBS r9, #0x01 
		CMP r9, #0x00 
		BEQ skip
		BNE repeat 

skip
		PUSH {r6}
		LDR r0, =newline
		BL putChar
		BL getval

opclear
		LDR r10, =0x00
		LDR r0, =newline
		BL putChar
		BL getval
		
		
repeat
		LDR r2, [r7, #-1]!
		AND r2, #mask
		LDR r5, =0x0A
		MUL r4, r5
		MUL r2, r4
		ADDS r6, r2
		SUBS r9, #0x01
		CMP r9, #0x00
		BNE repeat
		
		PUSH {r6}
		LDR r9, =0x00
		LDR r0, =newline
		BL putChar
		BL getval
				
addit
		POP {r8}
		POP {r9}
		ADD r8, r9
		PUSH {r8}
		LDR r10, =0x01
		BL getval
subit
		POP {r8}
		POP {r9}
		SUB r9, r8
		PUSH {r9}
		LDR r10, =0x01
		BL getval
mulit
		POP {r8}
		POP {r9}
		MUL r8, r9
		PUSH {r8}
		LDR r10, =0x01
		BL getval
divit
		POP {r8}
		POP {r9}
		CMP r8, #0
		BEQ divzeroerr
		
		UDIV r9, r8
		PUSH {r9}
		LDR r10, =0x01
		BL getval
equit
		LDR r0, =newline
		BL putChar

		POP {r0}      
		CMP r0, #0
		BEQ print_zero

		MOV r1, #10           

print_loop

		CMP r0, #0
		BLE print_neg
		
		MOV r3, r0             
		UDIV r3, r3, r1        
		MUL r4, r3, r1         
		SUB r5, r0, r4         
		ADDS r5, #0x30         

		PUSH {r5}
		MOV r0, r3             

		CMP r0, #0
		BNE print_loop

print_chars
		POP {r0}              
		CMP r0, #'0'
		BLT print_end
		BL putChar             
		B print_chars       

		B start

print_zero
		MOV r0, #0x30          
		BL putChar
		LDR r0, =newline
		BL putChar
		B start

print_end
		LDR r0, =newline
		BL putChar
		B start
		
print_neg
		NEG r0, r0
		PUSH {r0}
		MOV r0, #'-'
		BL putChar            
		POP {r0}
		B print_loop

divzeroerr
		LDR r0, =zeroerr
		BL putCharStr
		BL start
		
		ALIGN
		AREA MyData, DATA, READWRITE
			
startmsg DCB "\r\nUse RPN notation to enter an expression, then click ENTER after each argument and operator: \r\n",0 
zeroerr DCB "\r\n\nYou can't divide by zero!\r\n\n",0
outofrange DCB "\r\n\nThat is not a number!\r\n\n",0

toMemory SPACE 64
		END
	