package glassproject.ubicomp.com.todo.activity;

import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.os.Handler;
import android.os.IBinder;
import android.widget.RemoteViews;

import com.google.android.glass.timeline.LiveCard;

import glassproject.ubicomp.com.todo.R;
import glassproject.ubicomp.com.todo.db.TaskItemDb;
import glassproject.ubicomp.com.todo.model.TaskItem;

public class ToDoLiveCardService extends Service {
    private static final String LIVE_CARD_TAG = "ToDoLiveCard";

    private LiveCard mLiveCard;
    private RemoteViews mLiveCardView;

    private TaskItem taskItem;
    private TaskItemDb db;

    private final Handler mHandler = new Handler();
    private final UpdateLiveCardRunnable mUpdateLiveCardRunnable =
            new UpdateLiveCardRunnable();
    private static final long DELAY_MILLIS = 30000;

    @Override
    public void onCreate() {
        super.onCreate();
    }

    private void populateTaskOnView() {
        mLiveCardView.setTextViewText(R.id.taskDescription,
                taskItem.getTaskDescription());
//        if(taskItem.isRework())
//        {
//            mLiveCardView.setTextColor(R.id.taskDescription,Color.parseColor("#77aa70"));
//        }
        // Always call setViews() to update the live card's RemoteViews.
        mLiveCard.setViews(mLiveCardView);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (mLiveCard == null) {

            // Get an instance of a live card
            mLiveCard = new LiveCard(this, LIVE_CARD_TAG);

            db = new TaskItemDb(this);
            taskItem = db.getLatestTaskItem();
            // Inflate a layout into a remote view
            mLiveCardView = new RemoteViews(getPackageName(),
                    R.layout.to_do_live_card_screen);

            // Set up initial RemoteViews values
            if(taskItem != null) populateTaskOnView();

            // Set up the live card's action with a pending intent
            // to show a menu when tapped
            Intent menuIntent = new Intent(this, ToDoLiveCardActivity.class);
            menuIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK |
                    Intent.FLAG_ACTIVITY_CLEAR_TASK);
            mLiveCard.setAction(PendingIntent.getActivity(
                    this, 0, menuIntent, 0));

            // Publish the live card
            mLiveCard.publish(LiveCard.PublishMode.REVEAL);

            // Queue the update text runnable
            mHandler.post(mUpdateLiveCardRunnable);
        }
        return Service.START_NOT_STICKY;
    }

    @Override
    public void onDestroy() {
        if (mLiveCard != null && mLiveCard.isPublished()) {
            //Stop the handler from queuing more Runnable jobs
            mUpdateLiveCardRunnable.setStop(true);

            mLiveCard.unpublish();
            mLiveCard = null;
        }
        super.onDestroy();
    }

    /**
     * Runnable that updates live card contents
     */
    private class UpdateLiveCardRunnable implements Runnable{

        private boolean mIsStopped = false;

        /*
         * Updates the card with a fake score every 30 seconds as a demonstration.
         * You also probably want to display something useful in your live card.
         *
         * If you are executing a long running task to get data to update a
         * live card(e.g, making a web call), do this in another thread or
         * AsyncTask.
         */
        public void run(){
            if(!isStopped()){
                // Generate fake points.
                taskItem = db.getLatestTaskItem();

                // Update the remote view with the new scores.
                if(taskItem != null)
                    populateTaskOnView();

                // Queue another score update in 30 seconds.
                mHandler.postDelayed(mUpdateLiveCardRunnable, DELAY_MILLIS);
            }
        }

        public boolean isStopped() {
            return mIsStopped;
        }

        public void setStop(boolean isStopped) {
            this.mIsStopped = isStopped;
        }
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
