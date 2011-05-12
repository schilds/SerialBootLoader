%define UART_BASEADDR  0x3f8			; port
%define UART_BAUDRATE  0x1				; 115200 (port+0,1)
%define UART_LCRVAL    0x1b				; 8e1 (port+3)
%define UART_DLAB      0x80				; divisor latch access bit (port+3)
%define UART_RECV_STAT 0x9f             ; receive line status bits(port+5)
%define UART_CHAR_RECV 0x01				; character received bit
%define UART_RECV_ERR  0x9e             ; receive line status error bits


%define PACKET_FLAG    0x7e
%define CONTROL_FLAG   0x7d
%define PF_CID         0x5e
%define CF_CID         0x5d

[bits 16]
[org 0]
jmp 0x7c0:main							; boot sector

get_char:
	push dx
	mov  dx,UART_BASEADDR+5
	gc_wait:
		in   al,dx
		and  ax,UART_RECV_STAT
		jz   gc_wait

	xchg al,ah
	test ah,UART_CHAR_RECV
	jz   gc_nochar						; if no char, must be error
	mov  dx,UART_BASEADDR
	in   al,dx
	gc_nochar:
		pop  dx
		ret

parse_char:
	call get_char
	test ah,UART_RECV_ERR				; return line status bits if error
	jnz  parse_err
	cmp  al,PACKET_FLAG					; return null if packet flag
	je   parse_null
	cmp  al,CONTROL_FLAG				; return char if not control flag
	jne  parse_end
	call get_char						; get second character if first was control flag
	test ah,UART_RECV_ERR				; return line status bits if error
	jnz  parse_err
	cmp  al,PF_CID						; return PACKET_FLAG if PF_CID
	je   parse_pf_cid
	cmp  al,CF_CID						; return CONTROL_FLAG if CF_CID
	je   parse_cf_cid
	parse_null:							; return null
		xor  ah,ah						; no error, no character
		jmp  parse_end
	parse_pf_cid:
		mov  al,PACKET_FLAG				; return PACKET_FLAG
		jmp  parse_end
	parse_cf_cid:
		mov  al,CONTROL_FLAG			; return CONTROL_FLAG
		jmp  parse_end
	parse_err:
		and ah,UART_RECV_ERR			; error, no character (may not be necessary)
	parse_end:
		ret


main:
	cli									; disable interrupts

	mov  ax,cs							; set segment registers
	mov  ds,ax
	mov  es,ax
	mov  ss,ax

	mov  bp,0x7c00						; set up stack
	mov  sp,0x7c00

	sti									; enable interrupts
										; initialise the serial port
	mov  dx,UART_BASEADDR+3				; set divisor latch access bit
	mov  al,UART_DLAB
	out  dx,al
	mov  dx,UART_BASEADDR				; set divisor
	mov  ax,UART_BAUDRATE
	out  dx,ax
	mov  dx,UART_BASEADDR+3				; set bits, parity, stop bit
	mov  al,UART_LCRVAL
	out  dx,al
	mov  dx,UART_BASEADDR+4				; clear loopback
	xor  ax,ax
	out  dx,al
										; read and execute sequences of instructions from serial port
	find_packet:
		call get_char					; expecting packet flag
	test_packet_flag:
		test ah,UART_RECV_ERR
		jnz  find_packet
		cmp  al,PACKET_FLAG
		jne  find_packet

		call parse_char					; read length (2 bytes, little endian)
		test ah,UART_CHAR_RECV
		jz   test_packet_flag
		mov  cl,al

		call parse_char
		test ah,UART_CHAR_RECV
		jz   test_packet_flag
		mov  ch,al

		xor  dx,dx						; checksum (sum over buffer % 256)
		mov  di,buffer					; offset of buffer

		recv_loop:						; read bytes
			call parse_char
			test ah,UART_CHAR_RECV
			jz   test_packet_flag

			stosb

			and  ah,0					; accumulate checksum
			add  dx,ax
			and  dh,0

			loop recv_loop

		call parse_char					; read and compare checksum
		test ah,UART_CHAR_RECV
		jz   test_packet_flag
		cmp  al,dl
		jne  find_packet

		call get_char					; expecting packet flag
		test ah,UART_RECV_ERR
		jnz  find_packet
		cmp  al,PACKET_FLAG
		jne  find_packet

		call buffer						; run code in buffer
		jmp  find_packet				; look for more instructions

buffer:
	times 510 - ($-$$) db 0
	db 0x55, 0xaa						; boot sector magic number

