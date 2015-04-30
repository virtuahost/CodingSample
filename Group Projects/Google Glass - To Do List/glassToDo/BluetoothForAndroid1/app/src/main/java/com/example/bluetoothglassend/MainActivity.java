package com.example.bluetoothglassend;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothServerSocket;
import android.bluetooth.BluetoothSocket;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Set;
import java.util.UUID;

import static android.view.View.OnClickListener;

/*
    Software to be installed on Android Device
 */

public class MainActivity extends Activity {

    private static final UUID MY_UUID = UUID.fromString("0000110E-0000-1000-8000-00805F9B34FB");
	public static String msgToSend;
	public static final int STATE_CONNECTION_STARTED = 0;
	public static final int STATE_CONNECTION_LOST = 1;
	public static final int READY_TO_CONN = 2;
    public BluetoothSocket socket_conn;
	public volatile ConnectedThread mConnectedThread;

	BluetoothAdapter myBt;
	public String TAG = "log";
	public String NAME =" BLE";
    private Set<BluetoothDevice> pairedDevices;
	Handler handle;
    EditText inputField;
    Button submitButton;
    BroadcastReceiver receiver;

	ArrayList<BluetoothSocket> mSockets = new ArrayList<BluetoothSocket>();
	// list of addresses for devices we've connected to
	ArrayList<String> mDeviceAddresses = new ArrayList<String>();

	// We can handle up to 7 connections... or something...
	UUID[] uuids = new UUID[2];
	// some uuid's we like to use..
	String uuid1 = "00001101-0000-1000-8000-00805F9B34FB";
	String uuid2 = "c2911cd0-5c3c-11e3-949a-0800200c9a66";
	
	int REQUEST_ENABLE_BT = 1;
	AcceptThread accThread;
	TextView connectedDevice;


	@Override
	protected void onCreate(Bundle savedInstanceState) {

		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

        inputField = (EditText) findViewById(R.id.editText);
		uuids[0] = UUID.fromString(uuid1);
		uuids[1] = UUID.fromString(uuid2);
		
		connectedDevice = (TextView)findViewById(R.id.connectedDevice);
        submitButton = (Button)findViewById(R.id.task_submit);
		
		handle = new Handler(Looper.getMainLooper()) {

			@Override
			public void handleMessage(Message msg) {
				switch (msg.what) {
				// if connection is built.....
				case STATE_CONNECTION_STARTED:
					connectedDevice.setText("paired glass");				
					 Toast.makeText(getApplicationContext(), "bluetooth connected",
					 2).show();
					break;
				case STATE_CONNECTION_LOST:
					connectedDevice.setText("");
					// if the connection is broken, listening the device again
					startListening();
					break;
				case READY_TO_CONN:
					// if the connection is ready to go, start listening the
					// device
					startListening();
					break;
				default:
					break;
				}
			}

		};

		myBt = BluetoothAdapter.getDefaultAdapter();
		// run the "go get em" thread..
		accThread = new AcceptThread();
		accThread.start();

        /*
            Turn on Bluetooth, if switched off
         */
        if(!myBt.isEnabled()){
            Intent turnOn = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            startActivityForResult(turnOn, 0);
        }

        /* Display all paired devices */
        for (BluetoothDevice bluetoothDevice : pairedDevices = myBt.getBondedDevices()) {
            Toast.makeText(getApplicationContext(),"Showing Paired Devices "  + bluetoothDevice.getName(),
                    Toast.LENGTH_SHORT).show();

            Log.d(TAG, bluetoothDevice.getUuids().toString());
        }

        /*
        try {
            BluetoothServerSocket btss = myBt.listenUsingRfcommWithServiceRecord(temp_name, so_uuid);
        } catch (IOException e) {
            e.printStackTrace();
        }
        */
        /*
        if(device.getBondState()==device.BOND_BONDED)

        {
            Log.d(TAG, device.getName());
            //BluetoothSocket mSocket=null;
            try {
                mSocket = device.createInsecureRfcommSocketToServiceRecord(MY_UUID);
            } catch (IOException e1) {
                // TODO Auto-generated catch block
                Log.d(TAG, "socket not created");
                e1.printStackTrace();
            }
            try {
                mSocket.connect();
            } catch (IOException e) {
                try {
                    mSocket.close();
                    Log.d(TAG, "Cannot connect");
                } catch (IOException e1) {
                    Log.d(TAG, "Socket not closed");
                    e1.printStackTrace();
                }
            }
        }
        */
       // receiveMsg("select");
	}

    public void receiveMsg(final String input){
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Log.v(TAG, "Message Received on Android Device : " + input);
                inputField.setText(input);
            }
        });

    }

    public void startListening() {
		if (accThread != null) {
			accThread.cancel();
		} else if (mConnectedThread != null) {
			mConnectedThread.cancel();
		} else {
			accThread = new AcceptThread();
			accThread.start();
		}
	}
	
	public static class HostBroadRec extends BroadcastReceiver {
		@Override
		public void onReceive(Context context, Intent intent) {
			Bundle b = intent.getExtras();
			String vals = "";
			for (String key : b.keySet()) {
				vals += key + "&" + b.getString(key) + "Z";
			}
			MainActivity.setMsg(vals);
		}
	}
	
	private class ConnectedThread extends Thread {
		private final BluetoothSocket mmSocket;
		private final InputStream mmInStream;
		private final OutputStream mmOutStream;

		public ConnectedThread(BluetoothSocket socket) {
			
			Log.d(TAG, "create ConnectedThread");
			mmSocket = socket;
			InputStream tmpIn = null;
			OutputStream tmpOut = null;

			// Get the BluetoothSocket input and output streams
			try {
				tmpIn = socket.getInputStream();
				tmpOut = socket.getOutputStream();
			} catch (IOException e) {
				Log.e(TAG, "temp sockets not created", e);
			}
			mmInStream = tmpIn;
			mmOutStream = tmpOut;
		}

		//public void run() {
		//	Log.i(TAG, "BEGIN mConnectedThread");
		//	byte[] buffer = new byte[4];
		//	int bytes;
		//}

        @Override
        public void run() {
            int bufferSize = 1024*1024;
            byte[] buffer = new byte[bufferSize];
            try {
                //InputStream instream = mmsocket.getInputStream();
                int bytesRead = - 1;
                String message = "";
                while (true) {
                    message = "";
                    bytesRead = mmInStream.read(buffer);
                    if (bytesRead != -1) {
                        while ((bytesRead==bufferSize) && (buffer[bufferSize - 1] != 0)) {
                            message = message + new String(buffer, 0, bytesRead);
                            bytesRead = mmInStream.read(buffer);
                        }
                        message = message + new String(buffer, 0, bytesRead);
                        Log.v(TAG,"receiveMsg called");
                        receiveMsg(message);
                       // handler.post(new MessagePoster(textView, message));
                        //Toast.makeText(getApplicationContext(), "message received : " + message, 2).show();
                        mmSocket.getInputStream();
                    }
                }
            } catch (IOException e) {
                Log.d("BLUETOOTH_COMMS", e.getMessage());
            }
        }

		public void connectionLost() {
			Message msg = handle.obtainMessage(STATE_CONNECTION_LOST);
			handle.sendMessage(msg);
		}

		/**
		 * Write to the connected OutStream.
		 * 
		 * @param buffer
		 *            The bytes to write
		 */
		public void write(byte[] buffer) {
			try {
				// Toast.makeText(getApplicationContext(), "write buffer!",
				// 1).show();
				mmOutStream.write(buffer);
			} catch (IOException e) {
				Log.e(TAG, "Exception during write", e);
				connectionLost();
			}
		}

		public void cancel() {
			try {
				mmSocket.close();
				Message msg = handle.obtainMessage(READY_TO_CONN);
				handle.sendMessage(msg);
			} catch (IOException e) {
				Log.e(TAG, "close() of connect socket failed", e);
			}
		}

	}

	public static synchronized void setMsg(String newMsg) {
		msgToSend = newMsg;
	}
	
	private class AcceptThread extends Thread {
		private BluetoothServerSocket mmServerSocket;
		BluetoothServerSocket tmp;
         /*
            Add UUID from SO : Reference - http://stackoverflow.com/a/26301250/846797
        */

        private final UUID so_uuid = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");

        private final String temp_name = "gtodo";

        public AcceptThread() {

			BluetoothServerSocket tmp = null;

			try {
				tmp = myBt.listenUsingRfcommWithServiceRecord(temp_name, so_uuid);
			}
            catch (IOException e) {
			}
			mmServerSocket = tmp;
		}

		public void run() {
			Log.e(TAG, "Running");
			socket_conn = null;
			// Keep listening until exception occurs or a socket is returned
			while (true) {

				try {
					socket_conn = mmServerSocket.accept();
				} catch (IOException e) {
					e.printStackTrace();
					break;
				}
				// If a connection was accepted

				if (socket_conn != null) {
					// if the connection has been built, then close the server
					// socket..
					try {
						mmServerSocket.close();
					} catch (IOException e) {
						// TODO Auto-generated catch block
						e.printStackTrace();
					}
					// Do work to manage the connection (in a separate thread)
					manageConnectedSocket(socket_conn);
                    mConnectedThread = new ConnectedThread(socket_conn);
                    mConnectedThread.start();
					break;
				}
			}
		}

		/** Will cancel the listening socket, and cause the thread to finish */
		public void cancel() {
			try {
				mmServerSocket.close();
				Message msg = handle.obtainMessage(READY_TO_CONN);
				handle.sendMessage(msg);

			} catch (IOException e) {
			}
		}

	}

    public void btnClick(View view){
       // mConnectedThread = new ConnectedThread(socket_conn);
       // mConnectedThread.start();
        if(mConnectedThread != null){
            mConnectedThread.write(inputField.getText().toString().getBytes());
            Log.v(TAG,"Button Click with value : " + inputField.getText().toString() );
        }


    }

	private void manageConnectedSocket(BluetoothSocket socket) {
		// start our connection thread
		//mConnectedThread = new ConnectedThread(socket);
		//mConnectedThread.start();
        if(mConnectedThread != null){
            mConnectedThread.write("Start".getBytes());
            //mConnectedThread.start();
        }

		// Send the name of the connected device back to the UI Activity
		// so the HH can show you it's working and stuff...
		String devs = "";
		for (BluetoothSocket sock : mSockets) {
			devs += sock.getRemoteDevice().getName() + "\n";
		}
		// pass it to the pool....
		Message msg = handle.obtainMessage(STATE_CONNECTION_STARTED);
		Bundle bundle = new Bundle();
		bundle.putString("NAMES", devs);
		msg.setData(bundle);
		handle.sendMessage(msg);
	}

}


