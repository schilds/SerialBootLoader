package serialclient;

import gnu.io.CommPort;
import gnu.io.CommPortIdentifier;
import gnu.io.SerialPort;

import java.io.FileDescriptor;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.StringWriter;

public class TwoWaySerialComm
{

    public TwoWaySerialComm()
    {
        super();
    }

    void connect ( String portName ) throws Exception
    {
        CommPortIdentifier portIdentifier = CommPortIdentifier.getPortIdentifier(portName);
        if ( portIdentifier.isCurrentlyOwned() )
        {
            System.out.println("Error: Port is currently in use");
        }
        else
        {
            CommPort commPort = portIdentifier.open(this.getClass().getName(),2000);

            if ( commPort instanceof SerialPort )
            {
                SerialPort serialPort = (SerialPort) commPort;
                serialPort.setSerialPortParams(115200, SerialPort.DATABITS_8, SerialPort.STOPBITS_1, SerialPort.PARITY_EVEN);

                serialPort.setFlowControlMode(SerialPort.FLOWCONTROL_NONE);

                InputStream in = serialPort.getInputStream();
                OutputStream out = serialPort.getOutputStream();

                (new Thread(new SerialReader(in))).start();
                (new Thread(new SerialWriter(out))).start();

            }
            else
            {
                System.out.println("Error: Only serial ports are handled by this example.");
            }
        }
    }

    /** */
    public static class SerialReader implements Runnable
    {
        InputStream in;

        public SerialReader ( InputStream in )
        {
            this.in = in;
        }

        public void run ()
        {
            byte[] buffer = new byte[1024];
            int len = -1;
            try
            {
                while ( ( len = this.in.read(buffer)) > -1 )
                {
					if(len > 0)
                   		System.out.println(bytesToHexString(buffer, len));
                }
            }
            catch ( IOException e )
            {
                e.printStackTrace();
            }
        }
    }

    /** */
    public static class SerialWriter implements Runnable
    {
        OutputStream out;
        StringWriter buffer;

        public SerialWriter ( OutputStream out )
        {
            this.out = out;
            this.buffer = new StringWriter();
        }

        public void run ()
        {
            try
            {
                int c = 0;
                while ( ( c = System.in.read()) > -1 )
                {
					if(c != '\n')
						buffer.write(c);
                    else{
                    	this.out.write(new PacketInfo(hexStringToBytes(buffer.toString().trim())).packageBytes());
                    	buffer = new StringWriter();
                    }
                }
            }
            catch ( IOException e )
            {
                e.printStackTrace();
            }
        }
    }

    public static void main ( String[] args )
    {
        try
        {
            (new TwoWaySerialComm()).connect("COM1");
        }
        catch ( Exception e )
        {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

    private static byte[] hexStringToBytes(String s) {
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

	private static String bytesToHexString(byte[] bytes, int length){
		char[] hexArray = {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};
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
