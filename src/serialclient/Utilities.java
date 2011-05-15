package serialclient;

public class Utilities{
	public static byte[] hexStringToBytes(String s){
		s = s.replaceAll("\\s*", "");
		if(s.length() % 2 != 0)
			s += "0";
		int len = s.length();
		byte[] data = new byte[len / 2];
		for (int i = 0; i < len; i += 2) {
			data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4)
								 + Character.digit(s.charAt(i+1), 16));
		}
		return data;
	}

	public static String bytesToHexString(byte[] bytes, int length){
		char[] hexArray = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
		char[] hexChars = new char[length * 2];
		int v;
		for ( int j = 0; j < length; j++ ) {
			v = bytes[j] & 0xFF;
			hexChars[j*2] = hexArray[v/16];
			hexChars[j*2 + 1] = hexArray[v%16];
		}
		return new String(hexChars);
	}
}