package glassproject.ubicomp.com.todo.activity;

import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.graphics.Paint;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.speech.RecognizerIntent;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.glass.app.Card;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.Timer;
import java.util.TimerTask;
import java.util.UUID;

import glassproject.ubicomp.com.todo.R;
import glassproject.ubicomp.com.todo.db.TaskItemDb;
import glassproject.ubicomp.com.todo.model.TaskItem;

public class SingleTaskActivity extends Activity {

	private static final int SPEECH = 1836;
	private TaskItem taskItem;
	private TaskItemDb db;

    //Additions for UUID
    public BluetoothAdapter mBluetoothAdapter;
    public static final UUID MY_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");
    protected static final int SUCCESS_CONNECT = 0;
    protected static final int MESSAGE_READ = 1;
    String TAG = "SingleTask - Debug";
    BroadcastReceiver mReceiver;
    public TextView tv;

    ArrayList<BluetoothDevice> devices;
    IntentFilter filter;
    private Context context = this;
    BluetoothDevice selectedDevice;
    boolean bluetoothFlag = false;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.single_task_screen);
        tv = (TextView) findViewById(R.id.taskDescription);
		int id = getIntent().getIntExtra("taskItemId", -1);
		
		if(id == -1) {
			Toast.makeText(this, "Task id " + id + " not found!", Toast.LENGTH_SHORT).show();
			new Timer().schedule(new TimerTask() {
				@Override
				public void run() {
					finish();				
				} }, 1000);
		} else {
			db = new TaskItemDb(this);
			taskItem = db.getTaskItemById(id);
			populateTaskOnView();
		}
	}



	private void populateTaskOnView() {
		//TextView tv = (TextView) findViewById(R.id.taskDescription);
		tv.setText(taskItem.getTaskDescription());

        /* Start Bluetooth Connection */

        // init Bluetooth
        initBluetooth();

        //setup bluetooth adapter
        mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

        /* Scans and adds Bluetooth Connection */
        if (mBluetoothAdapter == null) {
            // Device does not support Bluetooth
            Toast toast = Toast.makeText(context, "Bluetooth disabled", 2);
            toast.show();
           // finish();
        }
        else{
            if (!mBluetoothAdapter.isEnabled()) {
                Toast toast = Toast.makeText(context, "please turn on your Bluetooth ", 2);
                toast.show();
                //push to the setting view to enable the bluetooth
                Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
                startActivityForResult(enableBtIntent, 1);
            }
            // Get all Bluetooth paired devices
            Set<BluetoothDevice> devicesArray = mBluetoothAdapter.getBondedDevices();
            // If there are devices
            if (devicesArray != null && devicesArray.size() > 0) {
                // Loop through paired devices
                Toast toast = Toast.makeText(context, "Bluetooth founded!", 0);
                toast.show();
                for (BluetoothDevice device : devicesArray) {
                   //add the name of each device to each card
                   // Card card = new Card(this);
                   // card.setText(device.getName());
                   //add the card to the array list
                   // mCards.add(card);

                    // Add Names of the three devices {Android}
                    Log.v(TAG, device.getName());
                    // Add specific names of devices
                   // if(device.getName() == ""){
                        bluetoothFlag = true;
                        selectedDevice = device;
                        break;
                   // }
                    //devices.add(device);
                }
               // setupScrollView();
            }

            if(mBluetoothAdapter.isDiscovering()){
                mBluetoothAdapter.cancelDiscovery();
            }

            //BluetoothDevice selectedDevice = devices.get(index);
            if(bluetoothFlag){
                ConnectThread connect = new ConnectThread(selectedDevice);
                connect.start();
            }
        }

        if(taskItem.isRework())
        {
            tv.setPaintFlags(Color.parseColor("#77aa70"));
        }
		if(taskItem.isDone()) {
			tv.setPaintFlags(tv.getPaintFlags() | Paint.STRIKE_THRU_TEXT_FLAG);
		} else {
			tv.setPaintFlags(tv.getPaintFlags() & (~Paint.STRIKE_THRU_TEXT_FLAG));
		}
	}
	

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		MenuInflater inflater = getMenuInflater();
		inflater.inflate(R.menu.single_task_menu, menu);
		return true;
	}
	
	@Override
    public boolean onPrepareOptionsMenu(Menu menu) {
        if(taskItem.isRework()){
            menu.findItem(R.id.rework_task_menu_item).setVisible(true);
            menu.findItem(R.id.mark_rework_done_menu_item).setVisible(true);
            menu.findItem(R.id.mark_done_menu_item).setVisible(false);
            menu.findItem(R.id.mark_not_done_menu_item).setVisible(false);
            menu.findItem(R.id.edit_task_menu_item).setVisible(false);
            menu.findItem(R.id.details_menu_item).setVisible(false);
            menu.findItem(R.id.details_rework_menu_item).setVisible(true);
        }else {
            menu.findItem(R.id.rework_task_menu_item).setVisible(false);
            menu.findItem(R.id.mark_rework_done_menu_item).setVisible(false);
            menu.findItem(R.id.edit_task_menu_item).setVisible(true);
            menu.findItem(R.id.details_menu_item).setVisible(true);
            menu.findItem(R.id.details_rework_menu_item).setVisible(false);
            if (taskItem.isDone()) {
                menu.findItem(R.id.mark_done_menu_item).setVisible(false);
                menu.findItem(R.id.mark_not_done_menu_item).setVisible(true);
            } else {
                menu.findItem(R.id.mark_done_menu_item).setVisible(true);
                menu.findItem(R.id.mark_not_done_menu_item).setVisible(false);
            }
        }
		
		return true;
	}
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_DPAD_CENTER) {
			openOptionsMenu();
			return true; 
		}
		return super.onKeyDown(keyCode, event);
	}
	
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case R.id.mark_done_menu_item:
			markDone();
			return true;
		case R.id.mark_not_done_menu_item:
			markNotDone();
			return true;
		case R.id.edit_task_menu_item:
			recordTask();
			return true;
        case R.id.rework_task_menu_item:
            reworkTask();
            return true;
        case R.id.mark_rework_done_menu_item:
            markReworkDone();
            return true;
		case R.id.delete_task_menu_item:
			deleteTask();
			return true;
        case R.id.details_menu_item:
            showMoreDetails();
            return true;
        case R.id.details_rework_menu_item:
            showMoreDetails();
            return true;
		default:
			return super.onOptionsItemSelected(item);
		}
	}

    private void showMoreDetails()
    {
        Intent intent = new Intent(this, MoreInfoActivity.class);
        intent.putExtra("loc", taskItem.getLoc());
        intent.putExtra("timeStamp", taskItem.getTimeStamp());
        startActivity(intent);
    }

	private void markDone() {
		taskItem.markDone(true);
		populateTaskOnView();
		db.updateTaskItem(taskItem);
		Toast.makeText(this, "Task marked done.", Toast.LENGTH_SHORT).show();
	}
	
	private void markNotDone() {
		taskItem.markDone(false);
		populateTaskOnView();
		db.updateTaskItem(taskItem);
		Toast.makeText(this, "Task marked not done.", Toast.LENGTH_SHORT).show();
	}

    private void markReworkDone() {
        taskItem.markDone(true);
        taskItem.markRework(true);
        populateTaskOnView();
        db.updateTaskItem(taskItem);
        Toast.makeText(this, "Task marked not done.", Toast.LENGTH_SHORT).show();
    }
	
	private void recordTask() {
		Intent intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
		startActivityForResult(intent, SPEECH);
	}

    private void reworkTask() {
        taskItem.markRework(false);
        Intent intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
        startActivityForResult(intent, SPEECH);
    }

	@Override
	protected void onActivityResult(int requestCode, int resultCode,
			Intent data) {
		if (requestCode == SPEECH && resultCode == RESULT_OK) {
			List<String> results = data.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS);
			String spokenText = results.get(0);
			taskItem.updateTaskDescription(spokenText);
			populateTaskOnView();
			db.updateTaskItem(taskItem);
			Toast.makeText(this, "Task updated.", Toast.LENGTH_SHORT).show();
		} else {
			Toast.makeText(this, "An error occurred. Please try again.", Toast.LENGTH_SHORT).show();
		}

		super.onActivityResult(requestCode, resultCode, data);
	}
	

	private void deleteTask() {
		db.deleteTaskItem(taskItem);
		((TextView) findViewById(R.id.taskDescription)).setVisibility(View.INVISIBLE);
		((TextView) findViewById(R.id.messageTextView)).setText("Task deleted");

		new Timer().schedule(new TimerTask() {
			@Override
			public void run() {
				finish();				
			} }, 1000);
	}

    public Handler mHandler;

    {
        mHandler = new Handler() {
            @Override
            public void handleMessage(Message msg) {
                // TODO Auto-generated method stub
                Log.i(TAG, "in handler");
                super.handleMessage(msg);
                switch (msg.what) {
                    case SUCCESS_CONNECT:
                        //read and write data from remote device
                        unregisterReceiver(mReceiver);
                        ConnectedThread connectedThread = new ConnectedThread((BluetoothSocket) msg.obj);
                        connectedThread.start();
                        //Add data field here :
                        connectedThread.write(tv.getText().toString().getBytes());

                        Toast.makeText(getApplicationContext(), "CONNECTED", 2).show();
                        //setContentView(R.layout.activity_main);
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

    /*
     * private initBluetooth
     * devices list added, will have to check what intent does
     * check filters
     */
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

    /*
    * Manage Data
    * Does input Stream
    * Parses Output Stream
    * */
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
                    buffer = new byte[1024];
                    bytes = mmInStream.read(buffer);
                    // Send the obtained bytes to the UI activity
                    mHandler.obtainMessage(MESSAGE_READ, bytes, -1, buffer)
                            .sendToTarget();
                    //Received the message
                    String message = "";
                    message = message + new String(buffer, 0, bytes);
                    updateTaskDescription(message);
                    Log.v(TAG, "Message Received on Glass: " + message);
                    Log.i(TAG, "message received!");

                } catch (IOException e) {
                    Log.i(TAG, "message failed!");
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

    /*  Client Connection  - Glass */
    private class ConnectThread extends Thread {

        private final BluetoothSocket mmSocket;
        private final BluetoothDevice mmDevice;

        public ConnectThread(BluetoothDevice device) {
            // Use a temporary object that is later assigned to mmSocket,
            // because mmSocket is final
            BluetoothSocket tmp = null;
            mmDevice = device;
            Log.i(TAG, "construct");
            // Get a BluetoothSocket to connect with the given BluetoothDevice
            try {
                // MY_UUID is the app's UUID string, also used by the server code
                tmp = device.createRfcommSocketToServiceRecord(MY_UUID);
            } catch (IOException e) {
                Log.i(TAG, "get socket failed");
            }
            mmSocket = tmp;
        }

        public void run() {
            // Cancel discovery because it will slow down the connection
            mBluetoothAdapter.cancelDiscovery();
            Log.i(TAG, "connect - run");
            try {
                // Connect the device through the socket. This will block
                // until it succeeds or throws an exception
                mmSocket.connect();
                Log.i(TAG, "connect - succeeded");
            } catch (IOException connectException) {
                Log.i(TAG, "connect failed");
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

    public void updateTaskDescription(final String message){
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Log.v(TAG, "Message Received on Glass : " + message);
                tv.setText(message);
            }
        });
    }
}
