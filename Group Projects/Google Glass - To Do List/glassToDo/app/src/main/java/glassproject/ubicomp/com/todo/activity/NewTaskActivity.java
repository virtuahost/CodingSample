package glassproject.ubicomp.com.todo.activity;

import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import glassproject.ubicomp.com.todo.R;
import glassproject.ubicomp.com.todo.db.TaskItemDb;
import glassproject.ubicomp.com.todo.model.TaskItem;


import android.annotation.SuppressLint;
import android.app.Activity;
//import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.speech.RecognizerIntent;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
//import android.view.MotionEvent;
import android.view.View;
import android.widget.TextView;

//import com.google.android.glass.touchpad.Gesture;
//import com.google.android.glass.touchpad.GestureDetector;

@SuppressLint("HandlerLeak")
public class NewTaskActivity extends Activity {

	private TaskItem createdTask = null;
	private TaskItemDb db;
	private Timer saveTimer;
//	private ToDoLiveCardService liveService;
	private final int SPEECH = 10284;

//    private GestureDetector mGestureDetector;
//    private TextViewGestureDetector objGestureDetector;
//    boolean inMenu = false;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		db = new TaskItemDb(this);
        Intent i= new Intent(this, ToDoLiveCardService.class);
        this.startService(i);
		setContentView(R.layout.new_task_screen);
//        objGestureDetector = new TextViewGestureDetector(this,this.obtainStyledAttributes() );
		recordTask();
	}

	private void recordTask() {
		Intent intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
		startActivityForResult(intent, SPEECH);
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode,
			Intent data) {
		if (requestCode == SPEECH && resultCode == RESULT_OK) {
			List<String> results = data.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS);
			String spokenText = results.get(0);
			createdTask = new TaskItem(spokenText);

			showTaskOnView(createdTask);
			
			saveTimer = new Timer();
			final int[] c = new int[]{3};
			saveTimer.schedule(new TimerTask() {
				@Override
				public void run() {
					if(c[0]==0) {
						saveTimer.cancel();
						saveTimer = null;
						saveHandler.sendEmptyMessage(0);
					} else {
						updateHandler.sendEmptyMessage(c[0]--);						
					}
				}				
			}, 1000, 1000);
		} else {
			((TextView) findViewById(R.id.newTaskLabel)).setVisibility(View.INVISIBLE);
			((TextView) findViewById(R.id.taskDescription)).setVisibility(View.INVISIBLE);
			
			((TextView) findViewById(R.id.messageTextView)).setVisibility(View.VISIBLE);
			((TextView) findViewById(R.id.messageTextView)).setText("An error occurred! Try again later.");
		}

		super.onActivityResult(requestCode, resultCode, data);
	}
	
	private Handler updateHandler = new Handler(){
        @Override
        public void handleMessage(Message msg) {
        	((TextView) findViewById(R.id.messageTextView)).setText("Saving in "+msg.what+" seconds\ntap for options");
        }
    };
    
    private Handler saveHandler = new Handler(){
        @Override
        public void handleMessage(Message msg) {
        	saveTask();
        }
    };


	private void showTaskOnView(TaskItem task) {
		((TextView) findViewById(R.id.newTaskLabel)).setVisibility(View.VISIBLE);
		((TextView) findViewById(R.id.taskDescription)).setVisibility(View.VISIBLE);
		((TextView) findViewById(R.id.taskDescription)).setText(task.getTaskDescription());
		
		((TextView) findViewById(R.id.messageTextView)).setVisibility(View.VISIBLE);
		((TextView) findViewById(R.id.messageTextView)).setText("tap for options");
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		MenuInflater inflater = getMenuInflater();
		inflater.inflate(R.menu.new_task_menu, menu);
		return true;
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		if (keyCode == KeyEvent.KEYCODE_DPAD_CENTER) {
			if(saveTimer  != null) {
				saveTimer.cancel();
				saveTimer = null;
				((TextView) findViewById(R.id.messageTextView)).setText("tap to options");
			}
//            inMenu = true;
//            objGestureDetector.onViewAttachedToWindow(((TextView) findViewById(R.id.record_again_menu_item)));
//            objGestureDetector.onViewAttachedToWindow(((TextView) findViewById(R.id.cancel_menu_item)));
//            mGestureDetector = createGestureDetector(this);
			openOptionsMenu();
			return true; 
		}
		return super.onKeyDown(keyCode, event);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case R.id.save_menu_item:
			saveTask();
			return true;
		case R.id.record_again_menu_item:
			recordTask();
			return true;
		case R.id.cancel_menu_item:
			finish();
//            inMenu = false;
//            objGestureDetector.onViewDetachedFromWindow(((TextView) findViewById(R.id.record_again_menu_item)));
//            objGestureDetector.onViewDetachedFromWindow(((TextView) findViewById(R.id.cancel_menu_item)));
			return true;
		default:
			return super.onOptionsItemSelected(item);
		}
	}

	public void saveTask() {
		db.saveTaskItem(createdTask);
		((TextView) findViewById(R.id.newTaskLabel)).setVisibility(View.VISIBLE);
		((TextView) findViewById(R.id.taskDescription)).setVisibility(View.VISIBLE);
		((TextView) findViewById(R.id.messageTextView)).setVisibility(View.VISIBLE);
		((TextView) findViewById(R.id.messageTextView)).setText("Saved.");
//        liveService = new ToDoLiveCardService();
//        Intent menuIntent = new Intent(this, NewTaskActivity.class);
//        liveService.onStartCommand(menuIntent,Intent.FLAG_ACTIVITY_SINGLE_TOP,-1);
		new Timer().schedule(new TimerTask() {
			@Override
			public void run() {
				finish();				
			} }, 1000);
	}

//    private GestureDetector createGestureDetector(Context context) {
//        GestureDetector gestureDetector = new GestureDetector(context);
//
//        //Create a base listener for generic gestures
//        gestureDetector.setBaseListener( new GestureDetector.BaseListener() {
//            @Override
//            public boolean onGesture(Gesture gesture) {
//                if (gesture == Gesture.SWIPE_DOWN && inMenu){
//                    saveTask();
//                }
//                return false;
//            }
//        });
//
//        gestureDetector.setFingerListener(new GestureDetector.FingerListener() {
//            @Override
//            public void onFingerCountChanged(int previousCount, int currentCount) {
//                // do something on finger count changes
//            }
//        });
//
//        gestureDetector.setScrollListener(new GestureDetector.ScrollListener() {
//            @Override
//            public boolean onScroll(float displacement, float delta, float velocity) {
//                // do something on scrolling
//                return true;
//            }
//        });
//
//        return gestureDetector;
//    }
//    @Override
//    public boolean onGenericMotionEvent(MotionEvent event) {
//        if (mGestureDetector != null) {
//            return mGestureDetector.onMotionEvent(event);
//        }
//        return false;
//    }
}
