package serialclient;

import javax.swing.*;
import java.awt.*;

public class SerialClient extends JFrame{

	private SerialControl serial_control;

	public SerialClient(){
		serial_control = new SerialControl();

		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setExtendedState(getExtendedState() | JFrame.MAXIMIZED_BOTH);
		setMinimumSize(new Dimension(500, 300));


		JTabbedPane tabbed_pane = new JTabbedPane();
		add(tabbed_pane);

		tabbed_pane.addTab("serial i/o", new SerialView(serial_control));
	}

	public static void main(String[] args){
		SwingUtilities.invokeLater(new Runnable(){
			public void run(){
				try{
					SerialClient client = new SerialClient();
					client.serial_control.connect("COM1");
					client.setVisible(true);
				}
				catch(Exception e){
					e.printStackTrace();
				}
			}
		});
	}
}
