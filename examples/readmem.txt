; specify start of memory block
bb 00 7c		; mov bx, 0000
be 00 00		; mov si, 0000

; start of transmit loop
ba fd 03		; mov dx 03fd 		-> dx = uart_addr + 5

; start of busy loop
ec			; in dx, al 		-> read contents of uart_addr + 5 into al
25 20 00		; and 0x20, ax 		-> test transmit status bits
74 fa			; je 			-> jump back to start of loop if not empty

; read and transmit byte from memory
ba f8 03		; mov dx 03f8 		-> dx = uart_addr
8a 00			; mov al, [bx+si]
ee			; out al, dx

; loop until si = 0x1d
46			; inc si
81 fe 1d 00		; and si, 0xff
72 ea			; je

c3			; return
