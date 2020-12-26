USE AT YOUR OWN RISK. This does not protect you in any way from exploding your computer.

The html client requires the serial api, see https://web.dev/serial/ (this feature may only be temporarily available)
The java client (was last worked on a decade ago) requires the rxtx library, see http://rxtx.qbang.org/wiki/ (apparently down?)

Material
- A usb flash drive.
- Device 1 (for experimenting on): an expendable device with a native serial port and a usb port.
- Device 2 (for developing on): a device with serial or usb ports, running Chrome with experimental features enabled.
- A serial cable (or usb to serial, or similar).

Instructions
1. Create a bootable usb from bin/loader.bin (e.g. see https://rufus.ie/).
2. Connect Device 1 and Device 2 with the serial cable.
3. Boot Device 1 from the usb.
4. Enable experimental features for Chrome on Device 2 (e.g. see https://web.dev/serial/).
5. Open bin/serialclient.html in Chrome on Device 2.
6. Press connect and select an appropriate COM port.
7. Copy and paste the contents of examples/hello.txt into the input box and press send.

Notes
- The bootloader polls the serial port in an infinite (and excessively) busy loop (unless the code transferred through the serial port does not return control to the bootloader). It will get your cpu's fan going, if nothing else.
- The serial packet format was shamelessly copied from somewhere else (now forgotten) and does some kind of primitive check to make sure the bytes are transferred ok (not to make sure it is valid x86).
- The bootloader assumes that it is given executable binary code. It's up to the user to make sure it is valid. The client accepts hexadecimal (the html version also accepts comments, but not the java version).
