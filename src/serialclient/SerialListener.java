package serialclient;

public interface SerialListener{
	public void bytesReceived(byte[] bytes, int length);
}