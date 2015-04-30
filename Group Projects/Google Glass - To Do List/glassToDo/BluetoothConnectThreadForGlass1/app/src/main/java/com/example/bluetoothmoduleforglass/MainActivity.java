package com.example.btglass;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import com.example.btglass.R;
import com.google.android.glass.app.Card;
import com.google.android.glass.touchpad.Gesture;
import com.google.android.glass.touchpad.GestureDetector;
import com.google.android.glass.widget.CardScrollAdapter;
import com.google.android.glass.widget.CardScrollView;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.UUID;

/*
  Software that is installed on Glass
 */
public class MainActivity extends Activity {

	private List<Card> mCards;
    private CardScrollView mCardScrollView;

    public static final UUID MY_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");
	public BluetoothAdapter mBluetoothAdapter;
	private Context context = this;
	Set<BluetoothDevice> devicesArray;
	ArrayList<BluetoothDevice> devices;
	BroadcastReceiver mReceiver;
	IntentFilter filter;

	protected static final int SUCCESS_CONNECT = 0;
	protected static final int MESSAGE_READ = 1;
	String tag = "debugging";
	
	GestureDetector mGestureDetector;

    public Handler mHandler;

    {
        mHandler = new Handler() {
            @Override
            public void handleMessage(Message msg) {
                // TODO Auto-generated method stub
                Log.i(tag, "in handler");
                super.handleMessage(msg);
                switch (msg.what) {
                    case SUCCESS_CONNECT:
                        //read and write data from remote device
                        unregisterReceiver(mReceiver);
                        ConnectedThread connectedThread = new ConnectedThread((BluetoothSocket) msg.obj);
                        connectedThread.start();
                        connectedThread.write("ashwini".getBytes());
                        Log.v(tag, "Ready to send data");
                        Toast.makeText(getApplicationContext(), "CONNECTED - Ready to send data", 2).show();
                        setContentView(R.layout.activity_main);
                        break;
                    case MESSAGE_READ:
                        byte[] readBuf = (byte[]) msg.obj;
                        int bufferContent = ByteBuffer.wrap(readBuf).getInt();
                        String string = new String(readBuf);
                        break;
                }
            }
        };
    }

    @Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		
		 //initialize an array list of card object, which works the same as the list view..
		   mCards = new ArrayList<Card>();
		   mGestureDetector = this.createGestureDetector(this);
			
		   initBluetooth();
			//check the bluetooth
		   mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
		   if (mBluetoothAdapter == null) {
			    // Device does not support Bluetooth
				Toast toast = Toast.makeText(context, "Bluetooth disabled", 2);
				toast.show();
				finish();	
		   }
		   else
		   {
				if (!mBluetoothAdapter.isEnabled()) {
					
					Toast toast = Toast.makeText(context, "please turn on your Bluetooth ", 2);
					toast.show();
					//push to the setting view to enable the bluetooth
				    Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
				    startActivityForResult(enableBtIntent, 1);
				}
				Set<BluetoothDevice> devicesArray = mBluetoothAdapter.getBondedDevices();
				// If there are devices
				if (devicesArray != null && devicesArray.size() > 0) {
				    // Loop through paired devices
					Toast toast = Toast.makeText(context, "Bluetooth founded!", 0);
					toast.show();
				    for (BluetoothDevice device : devicesArray) {
						//add the name of each device to each card
						Card card = new Card(this);
						card.setText(device.getName());
						//add the card to the array list
						mCards.add(card);
						devices.add(device);	    	
				    }
				    setupScrollView();
				}
		   }		
	}
	
	private void setupScrollView(){
       mCardScrollView = new CardScrollView(this){
    	   @Override
           public final boolean dispatchGenericFocusedEvent(MotionEvent event) {
               if (mGestureDetector.onMotionEvent(event)) {
                   return true;
               }
               return super.dispatchGenericFocusedEvent(event);
           }
       };
       
       ExampleCardScrollAdapter adapter = new ExampleCardScrollAdapter();
       mCardScrollView.setAdapter(adapter);
       mCardScrollView.activate();
       setContentView(mCardScrollView);
         
       mBluetoothAdapter.cancelDiscovery();
       mBluetoothAdapter.startDiscovery();
	}
    private  void initBluetooth(){
        devices = new ArrayList<BluetoothDevice>();
        // Create a BroadcastReceiver for ACTION_FOUND
        mReceiver = new BroadcastReceiver() {
            //once the receiver receives an action, it will break and stop receiving notifications.
            public void onReceive(Context context, Intent intent) {
                String action = intent.getAction();
                // When discovery finds a device
                if (BluetoothDevice.ACTION_FOUND.equals(action)) {
                    // Get the BluetoothDevice object from the Intent
                    BluetoothDevice device = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE);

                    Card card = new Card(getApplicationContext());
                    card.setText(device.getName());
                    mCards.add(card);
                    devices.add(device);
                    //pairedDevices.add(device.getName());
                }
            }
        };
        // Register the BroadcastReceiver
        filter = new IntentFilter(BluetoothDevice.ACTION_FOUND);
        registerReceiver(mReceiver, filter); // Don't forget to unregister during onDestroy
        filter = new IntentFilter(BluetoothAdapter.ACTION_DISCOVERY_STARTED);
        registerReceiver(mReceiver, filter);
        filter = new IntentFilter(BluetoothAdapter.ACTION_DISCOVERY_FINISHED);
        registerReceiver(mReceiver, filter);
        filter = new IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED);
        registerReceiver(mReceiver, filter);
    }


	private GestureDetector createGestureDetector(final Context context) {
		
		GestureDetector mGestureDetector = new GestureDetector(context);
		mGestureDetector.setBaseListener(new GestureDetector.BaseListener() {
			
			 @Override
	        public boolean onGesture(Gesture gesture) {
	            if (gesture == Gesture.TAP) {
	            	int index = mCardScrollView.getSelectedItemPosition();
	    			Log.d(tag, Integer.toString(index));
	    			
	    			if(mBluetoothAdapter.isDiscovering()){
	    				mBluetoothAdapter.cancelDiscovery();
	    			}
					BluetoothDevice selectedDevice = devices.get(index);
					ConnectThread connect = new ConnectThread(selectedDevice);
					connect.start();
					Log.i(tag, "clicked");
	                return true;
	            }
	            return false;
	        }
	    });	
	    return mGestureDetector;
	}


	/* Manage Data */
	private class ConnectedThread extends Thread {

	    private final BluetoothSocket mmSocket;
	    private final InputStream mmInStream;
	    private final OutputStream mmOutStream;
	 
	    public ConnectedThread(BluetoothSocket socket) {
	        mmSocket = socket;
	        InputStream tmpIn = null;
	        OutputStream tmpOut = null;
	        // Get the input and output streams, using temp objects because
	        // member streams are final
	        try {
	            tmpIn = socket.getInputStream();
	            tmpOut = socket.getOutputStream();
	        } catch (IOException e) { }
	 
	        mmInStream = tmpIn;
	        mmOutStream = tmpOut;
	    }
	 
	    public void run() {
	        byte[] buffer;  // buffer store for the stream
	        int bytes; // bytes returned from read()

	        // Keep listening to the InputStream until an exception occurs
	        while (true) {
	            try {
	                // Read from the InputStream
	            	buffer = new byte[1024*1024];
	                bytes = mmInStream.read(buffer);
	                // Send the obtained bytes to the UI activity

                    //Received the message
                    String message = "";
                    message = message + new String(buffer, 0, bytes);
                    Log.v(tag, "Message Received on Glass: " + message);
	                mHandler.obtainMessage(MESSAGE_READ, bytes, -1, buffer)
	                .sendToTarget(); 
	                Log.i(tag, "message received!");
                    //Toast.makeText(getApplicationContext(), "message Received " + message, 2).show();
	            } catch (IOException e) {
	            	Log.i(tag, "message failed!");
	                break;
	            }
	        }
	    }
	 
	    /* Call this from the main activity to send data to the remote device */
	    public void write(byte[] bytes) {
	        try {
	            mmOutStream.write(bytes);
	        } catch (IOException e) { }
	    }
	 
	    /* Call this from the main activity to shutdown the connection */
	    public void cancel() {
	        try {
	            mmSocket.close();
	        } catch (IOException e) { }
	    }   
	}


    /* Client Connection */
	private class ConnectThread extends Thread {

		private final BluetoothSocket mmSocket;
	    private final BluetoothDevice mmDevice;
	   
	    public ConnectThread(BluetoothDevice device) {
	        // Use a temporary object that is later assigned to mmSocket,
	        // because mmSocket is final
	        BluetoothSocket tmp = null;
	        mmDevice = device;
	        Log.i(tag, "construct");
	        // Get a BluetoothSocket to connect with the given BluetoothDevice
	        try {
	            // MY_UUID is the app's UUID string, also used by the server code
	            tmp = device.createRfcommSocketToServiceRecord(MY_UUID);
	        } catch (IOException e) { 
	        	Log.i(tag, "get socket failed");	
	        }
	        mmSocket = tmp;
	    }
	 
	    public void run() {
	        // Cancel discovery because it will slow down the connection
	        mBluetoothAdapter.cancelDiscovery();
	        Log.i(tag, "connect - run");
	        try {
	            // Connect the device through the socket. This will block
	            // until it succeeds or throws an exception
	            mmSocket.connect();
	            Log.i(tag, "connect - succeeded");
	        } catch (IOException connectException) {	
	        	Log.i(tag, "connect failed");
	            // Unable to connect; close the socket and get out
	            try {
	                mmSocket.close();
	            } catch (IOException closeException) { }
	            return;
	        }
	        // Do work to manage the connection, the handler will send the connecting successful message with the socket back to the pool
	        mHandler.obtainMessage(SUCCESS_CONNECT, mmSocket).sendToTarget();
            // manage connected socket
            // manageConnectedSocket(mmSocket);
	    }
	 
		/** Will cancel an in-progress connection, and close the socket */
	    public void cancel() {
	        try {
	            mmSocket.close();
	        } catch (IOException e) { }
	    }
	}
	
	private class ExampleCardScrollAdapter extends CardScrollAdapter {
		//the same as implementing a list view
        
		public int findIdPosition(Object id) {
            return -1;
        }

        public int findItemPosition(Object item) {
            return mCards.indexOf(item);
        }

        @Override
        public int getCount() {
            return mCards.size();
        }

        @Override
        public Object getItem(int position) {
            return mCards.get(position);
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {
            return mCards.get(position).getView();
        }

		@Override
		public int getPosition(Object arg0) {
			// TODO Auto-generated method stub
			return 0;
		}
    }
}
