package glassproject.ubicomp.com.todo.activity;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.media.AudioManager;
import android.media.SoundPool;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.speech.RecognizerIntent;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.TextView;

import com.google.android.glass.timeline.LiveCard;
import com.google.android.glass.view.WindowUtils;

import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

import glassproject.ubicomp.com.todo.R;
import glassproject.ubicomp.com.todo.db.TaskItemDb;
import glassproject.ubicomp.com.todo.model.TaskItem;

/**
 * Created by Deep on 3/9/2015.
 */
public class ToDoTaskListActivity extends Activity {
    private TaskItem createdTask = null;
    private TaskItemDb db;
    private ToDoLiveCardService liveService;
//    private final SoundPool mSoundPool;
//    final int mFinishSoundId;
    private static final int SOUND_PRIORITY = 1;
    private static final int MAX_STREAMS = 1;
    private final int SPEECH = 10284;

    private void performActionsIfConnected() {
    }

//    public ToDoTaskListActivity()
//    {
//        mSoundPool = new SoundPool(MAX_STREAMS, AudioManager.STREAM_MUSIC, 0);
//        mFinishSoundId = mSoundPool.load(this, R.raw.tinybellsms, SOUND_PRIORITY);
//    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        db = new TaskItemDb(this);
        Intent i= new Intent(this, ToDoLiveCardService.class);
        this.startService(i);
        setContentView(R.layout.todo_task_screen);
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
            createdTask = new TaskItem(-1,spokenText,false,-1,true,"","");

//            showTaskOnView(createdTask);

            saveTask();
        } else {
            ((TextView) findViewById(R.id.newTaskLabel)).setVisibility(View.INVISIBLE);
            ((TextView) findViewById(R.id.taskDescription)).setVisibility(View.INVISIBLE);

            ((TextView) findViewById(R.id.messageTextView)).setVisibility(View.VISIBLE);
            ((TextView) findViewById(R.id.messageTextView)).setText("An error occurred! Try again later.");
        }

        new Timer().schedule(new TimerTask() {
            @Override
            public void run() {
                finish();
            } }, 200);
        super.onActivityResult(requestCode, resultCode, data);
    }


    private void showTaskOnView(TaskItem task) {
        ((TextView) findViewById(R.id.newTaskLabel)).setVisibility(View.VISIBLE);
        ((TextView) findViewById(R.id.taskDescription)).setVisibility(View.VISIBLE);
        ((TextView) findViewById(R.id.taskDescription)).setText(task.getTaskDescription());
    }


    public void saveTask() {
        db.saveTaskItem(createdTask);
        ((TextView) findViewById(R.id.newTaskLabel)).setVisibility(View.VISIBLE);
        ((TextView) findViewById(R.id.taskDescription)).setVisibility(View.VISIBLE);
        ((TextView) findViewById(R.id.messageTextView)).setVisibility(View.VISIBLE);
        ((TextView) findViewById(R.id.messageTextView)).setText("Saved.");
//        mSoundPool.play(mFinishSoundId, 1, 1, SOUND_PRIORITY, 0, 1);

    }
}
