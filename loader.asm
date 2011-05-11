.286
.model	TINY
.const
		UART_BASEADDR	equ		3f8h	; comm 1
		UART_BAUDRATE	equ		1		; baud rate 115200
		UART_LCRVAL		equ		1bh		; 8e1
		UART_FCRVAL		equ		c7h
		UART_DLAB		equ		80h		; msb bit is dlab
		UART_CHAR_RECV	equ		1

		PACKET_FLAG		equ		7eh
		CONTROL_FLAG	equ		7dh
		PF_CID			equ		5eh
		CF_CID			equ		5dh
.code   
org		07c00h							; boot sector

start:
		jmp  main						; start


get_char proc near
		push dx
		mov  dx,UART_BASEADDR+5
gc_wait:
		in   al,dx
		xchg al,ah
		and  ax,9f00h
		jnz  gc_wait_end
		jmp  gc_wait					
gc_wait_end:
		test ah,UART_CHAR_RECV
		jz   gc_nochar					; if no char, must be error
		mov  dx,UART_BASEADDR
		in   al,dx
gc_nochar:
		pop  dx
		ret
get_char endp

parse_char proc near
		call get_char
		test ah,UART_CHAR_RECV			; return null if error
		jz   parse_null		
		cmp  al,PACKET_FLAG				; return null if packet flag
		je   parse_null		
		cmp  al,CONTROL_FLAG			; return char if not control flag
		jne  parse_end
		call get_char					; get second character if first was control flag
		test ah,UART_CHAR_RECV			; return null if error
		jz   parse_null
		cmp  al,PF_CID					; return PACKET_FLAG if PF_CID
		je   parse_pf_cid
		cmp  al,CF_CID					; return CONTROL_FLAG if CF_CID
		je   parse_cf_cid
parse_null:								; return null
		and  ah,0feh						
		jmp  parse_end
parse_pf_cid:
		mov  al,PACKET_FLAG
		jmp  parse_end
parse_cf_cid:
		mov  al,CONTROL_FLAG
parse_end:
		ret
parse_char endp

 


main:	
		cli								; disable interrupts

		mov  ax,cs						; set segment registers
		mov  ds,ax
		mov  es,ax
		mov  ss,ax    

		mov  bp,7c00h					; set up stack
		mov  sp,7c00h					

		sti								; enable interrupts
										; initialise the serial port
		mov  dx,UART_BASEADDR+3			; set divisor latch access bit
		mov  al,UART_DLAB
		out  dx,al
		mov  dx,UART_BASEADDR			; set divisor
		mov  ax,UART_BAUDRATE	
		out  dx,ax
		mov  dx,UART_BASEADDR+3			; set bits, parity, stop bit
		mov  al,UART_LCRVAL
		out  dx,al
		mov  dx,UART_BASEADDR+4			; clear loopback
		xor  ax,ax
		out  dx,al
										; read and execute sequences of instructions from serial port
find_packet:
		call get_char					; expecting packet flag
		test ah,UART_CHAR_RECV
		jz   find_packet
		cmp  al,PACKET_FLAG
		jne  find_packet

		call parse_char					; read length (2 bytes, little endian)
		test ah,UART_CHAR_RECV
		jz   find_packet
		mov  cl,al

		call parse_char
		test ah,UART_CHAR_RECV
		jz   find_packet
		mov  ch,al
				
		xor  dx,dx						; checksum (sum over buffer % 256)
		mov  di,offset buffer			; offset of buffer
recv_loop:								; read bytes
		call parse_char
		test ah,UART_CHAR_RECV
		jz   find_packet

		stosb

		and  ah,0						; accumulate checksum
		add  dx,ax
		and  dh,0

		loop recv_loop
recv_loop_end:
		call parse_char					; read and compare checksum
		test ah,UART_CHAR_RECV
		jz   find_packet
		cmp  al,dl
		jne  find_packet
		
		call get_char					; expecting packet flag
		test ah,UART_CHAR_RECV
		jz   find_packet
		cmp  al,PACKET_FLAG
		jne  find_packet
				
		call serial_code				; run code in buffer
		jmp  find_packet				; look for more instructions


code_size = $ - start

serial_code:
buffer	db  510 - code_size dup (0)
		db	055h, 0aah					; boot sector magic number

end	start