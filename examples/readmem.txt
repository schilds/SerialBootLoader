; specify start of memory block, so happens to be the start of this code
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

; loop until si = 1d, so happens to be the length of this code
46			; inc si
81 fe 1d 00		; cmp si, 001d
72 ea			; jb

c3			; return
