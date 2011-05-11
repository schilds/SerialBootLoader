package serialclient;


public class PacketInfo {
	public int length, checksum;

	public PacketInfo(){
		length = 5; // 1 byte start, 1 byte end packet flags + 2 bytes length + 1 byte checksum
		checksum = 0;
	}
}
