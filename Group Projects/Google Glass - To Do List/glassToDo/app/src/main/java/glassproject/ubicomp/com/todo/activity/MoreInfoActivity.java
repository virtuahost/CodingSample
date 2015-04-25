package glassproject.ubicomp.com.todo.activity;

import android.app.Activity;
import android.graphics.Color;
import android.graphics.Paint;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.widget.TextView;
import android.widget.Toast;

import java.util.Timer;
import java.util.TimerTask;

import glassproject.ubicomp.com.todo.R;
import glassproject.ubicomp.com.todo.db.TaskItemDb;
import glassproject.ubicomp.com.todo.model.TaskItem;

public class MoreInfoActivity extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.more_info_screen);
        String loc = getIntent().getStringExtra("loc");
        String timeStamp = getIntent().getStringExtra("timeStamp");
        TextView tv = (TextView) findViewById(R.id.locDescription);
        tv.setText("Location of entry: " + loc);
        tv = (TextView) findViewById(R.id.timeStampDescription);
        tv.setText("Date of entry: " + timeStamp);
	}
}
