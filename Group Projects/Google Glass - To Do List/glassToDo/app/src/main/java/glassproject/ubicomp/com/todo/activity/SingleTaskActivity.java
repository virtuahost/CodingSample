package glassproject.ubicomp.com.todo.activity;

import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import android.app.Activity;
import android.app.Notification;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Paint;
import android.os.Bundle;
import android.speech.RecognizerIntent;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import glassproject.ubicomp.com.todo.R;
import glassproject.ubicomp.com.todo.db.TaskItemDb;
import glassproject.ubicomp.com.todo.model.TaskItem;

public class SingleTaskActivity extends Activity {

	private static final int SPEECH = 1836;
	private TaskItem taskItem;
	private TaskItemDb db;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.single_task_screen);

		int id = getIntent().getIntExtra("taskItemId", -1);
		
		if(id==-1) {
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
		TextView tv = (TextView) findViewById(R.id.taskDescription);
		tv.setText(taskItem.getTaskDescription());

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
}
