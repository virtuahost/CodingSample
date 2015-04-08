package glassproject.ubicomp.com.todo.activity;

import android.app.Activity;
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

import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import glassproject.ubicomp.com.todo.R;
import glassproject.ubicomp.com.todo.db.TaskItemDb;
import glassproject.ubicomp.com.todo.model.TaskItem;

public class ToDoLiveCardActivity extends Activity {

	private static final int SPEECH = 1836;
	private TaskItem taskItem;
	private TaskItemDb db;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.to_do_live_card_screen);

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
        inflater.inflate(R.menu.todo_live_card_task_menu, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.details_todo_menu_item:
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

    @Override
    public void onOptionsMenuClosed(Menu menu) {
        // Nothing else to do, closing the activity.
        finish();
    }

    @Override
    public void onAttachedToWindow() {
        super.onAttachedToWindow();
        openOptionsMenu();
    }
}
