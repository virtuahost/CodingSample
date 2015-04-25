package glassproject.ubicomp.com.todo.db;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.location.Address;
import android.location.Criteria;
import android.location.Geocoder;
import android.location.Location;
import android.location.LocationManager;
import android.text.TextUtils;
import android.util.Log;

import glassproject.ubicomp.com.todo.R;
import glassproject.ubicomp.com.todo.model.TaskItem;

public class TaskItemDb extends SQLiteOpenHelper{
	
	private static String TAG = "TaskItemDb";
    private Context currContext;
	private static final int DATABASE_VERSION = 4;
	
	private static final String DATABASE_NAME = "taskDB.db";
	private static final String TABLE_TASKS = "tasks";
	
	public static final String COLUMN_ID = "_id";
	public static final String COLUMN_TASKDESCRIPTION = "taskdescription";
	public static final String COLUMN_DONE = "done";
	public static final String COLUMN_ORDER = "ord";
    public static final String COLUMN_REWORK = "rework";
    public static final String COLUMN_TIMESTAMP = "timestamp";
    public static final String COLUMN_LOC = "loc";
	
	public static final String COLUMN_URGENCY = "urgency";
	public static final String COLUMN_IMPORTANCE = "importance";
	public static final String COLUMN_DEADLINE = "deadline";
	public static final String COLUMN_TAGS = "tags";
	
	public TaskItemDb(Context context) {
		super(context, DATABASE_NAME, null, DATABASE_VERSION);
        currContext = context;
	}
	
	@Override
	public void onCreate(SQLiteDatabase db) {
		
		String CREATE_PRODUCTS_TABLE = "CREATE TABLE " +
	             TABLE_TASKS + "("
				 + COLUMN_ID + " INTEGER PRIMARY KEY," 
				 + COLUMN_TASKDESCRIPTION + " TEXT,"
				 + COLUMN_DONE + " INTEGER,"
				 + COLUMN_ORDER + " INTEGER,"
                + COLUMN_REWORK + " INTEGER,"
                + COLUMN_TIMESTAMP + " TEXT,"
                + COLUMN_LOC + " TEXT,"
				 
				 + COLUMN_URGENCY + " INTEGER," 
				 + COLUMN_IMPORTANCE + " INTEGER," 
				 + COLUMN_DEADLINE + " TEXT," 
	             + COLUMN_TAGS + " TEXT" + ")";
	      db.execSQL(CREATE_PRODUCTS_TABLE);

	}

	@Override
	public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
		db.execSQL("DROP TABLE IF EXISTS " + TABLE_TASKS);
	    onCreate(db);
	}
	
	public void saveTaskItem(TaskItem item) {
		String query = "Select MAX("+COLUMN_ORDER+") FROM " + TABLE_TASKS;
		SQLiteDatabase db = this.getWritableDatabase();
		Cursor cursor = db.rawQuery(query, null);
		
		int max_order;		
		if (cursor.moveToFirst()) {
			cursor.moveToFirst();
			max_order = cursor.getInt(0) + 1;
			cursor.close();
		} else {
			max_order = 1;
		}
		
		ContentValues values = new ContentValues();
        values.put(COLUMN_TASKDESCRIPTION, item.getTaskDescription());
        values.put(COLUMN_DONE, item.isDone() ? 1 : 0);
        values.put(COLUMN_ORDER, max_order);
        values.put(COLUMN_REWORK, item.isRework()?1:0);
        values.put(COLUMN_TIMESTAMP, Calendar.getInstance().get(Calendar.MONTH) + "/ " + Calendar.getInstance().get(Calendar.DATE) + "/ " + Calendar.getInstance().get(Calendar.YEAR));
        values.put(COLUMN_LOC, getLocation(currContext));
        
        values.put(COLUMN_URGENCY, item.getUrgency());
        values.put(COLUMN_IMPORTANCE, item.getImportance());
        values.put(COLUMN_DEADLINE, item.getDeadline());
        values.put(COLUMN_TAGS, item.getTags());

        db.insert(TABLE_TASKS, null, values);
        db.close();
	}	
	
	public TaskItem getTaskItemById(int tid) {
		String query = "Select "
				+ COLUMN_ID + ","
				+ COLUMN_TASKDESCRIPTION + ","
				+ COLUMN_DONE + ","
				+ COLUMN_ORDER + ","
                + COLUMN_TIMESTAMP + ","
                + COLUMN_LOC + ","
                + COLUMN_REWORK + " FROM " + TABLE_TASKS
				+ " WHERE " + COLUMN_ID + " =  \"" + tid + "\"";
		
		SQLiteDatabase db = this.getWritableDatabase();
		Cursor cursor = db.rawQuery(query, null);
		
		TaskItem taskItem;
		
		if (cursor.moveToFirst()) {
			cursor.moveToFirst();
			
			int id = cursor.getInt(0);
			String taskDescription = cursor.getString(1);
			int done = cursor.getInt(2);
			int order = cursor.getInt(3);
            int rework = cursor.getInt(6);
            String tmStamp = cursor.getString(4);
            String loctn = cursor.getString(5);
			taskItem = new TaskItem(id, taskDescription, done==0 ? false : true, order,rework==0 ? false : true,tmStamp,loctn);
			
			cursor.close();
		} else {
			taskItem = null;
		}
		
		db.close();
		return taskItem;
	}
	
	public void updateTaskItem(TaskItem newTask){
		ContentValues values = new ContentValues();
        values.put(COLUMN_TASKDESCRIPTION, newTask.getTaskDescription());
        values.put(COLUMN_DONE, newTask.isDone() ? 1 : 0);
        values.put(COLUMN_ORDER, newTask.getOrder());
        values.put(COLUMN_REWORK, newTask.isRework()?1:0);
        values.put(COLUMN_LOC, newTask.getLoc());
        values.put(COLUMN_TIMESTAMP, newTask.getTimeStamp());

        values.put(COLUMN_URGENCY, newTask.getUrgency());
        values.put(COLUMN_IMPORTANCE, newTask.getImportance());
        values.put(COLUMN_DEADLINE, newTask.getDeadline());
        values.put(COLUMN_TAGS, newTask.getTags());
		
		SQLiteDatabase db = this.getWritableDatabase();
		String tempStr = String.valueOf(newTask.getID());
		db.update(TABLE_TASKS, values, COLUMN_ID + "=" +tempStr ,null);
		db.close();
		
	}
	
	public List<TaskItem> getAllTaskItems() {
		String query = "Select " 
				+ COLUMN_ID + "," 
				+ COLUMN_TASKDESCRIPTION + "," 
				+ COLUMN_DONE + ","
				+ COLUMN_ORDER + ","
                + COLUMN_TIMESTAMP + ","
                + COLUMN_LOC + ","
                + COLUMN_REWORK + " FROM " + TABLE_TASKS
				+ " ORDER BY " + COLUMN_ORDER;
		
		SQLiteDatabase db = this.getWritableDatabase();
		
		ArrayList<TaskItem> allTaskItems = new ArrayList<TaskItem>();
		
		Cursor cursor = db.rawQuery(query, null);
		
		if (cursor.moveToFirst()) {
			cursor.moveToFirst();
			while(!cursor.isAfterLast()){
				int id = cursor.getInt(0);
				String taskDescription = cursor.getString(1);
				int done = cursor.getInt(2);
				int order = cursor.getInt(3);
                int rework = cursor.getInt(6);
                String tmStamp = cursor.getString(4);
                String loctn = cursor.getString(5);
				allTaskItems.add(new TaskItem(id, taskDescription, done==0 ? false : true, order,rework==0 ? false : true,tmStamp,loctn));
				cursor.moveToNext();
			}
			cursor.close();
		}

		db.close();
		return allTaskItems;
	}
	
	public void deleteTaskItem(TaskItem item) {
		SQLiteDatabase db = this.getWritableDatabase();
		db.delete(TABLE_TASKS, COLUMN_ID + " = " + item.getID(), null);
	}

    public TaskItem getLatestTaskItem()
    {
        String query = "Select "
                + COLUMN_ID + ","
                + COLUMN_TASKDESCRIPTION + ","
                + COLUMN_DONE + ","
                + COLUMN_ORDER + ","
                + COLUMN_TIMESTAMP + ","
                + COLUMN_LOC + ","
                + COLUMN_REWORK + " FROM " + TABLE_TASKS
                + " WHERE " + COLUMN_DONE + " =  \"" + "0" + "\""
                + " ORDER BY DEADLINE ASC LIMIT 1";

        SQLiteDatabase db = this.getWritableDatabase();
        Cursor cursor = db.rawQuery(query, null);

        TaskItem taskItem;

        if (cursor.moveToFirst()) {
            cursor.moveToFirst();

            int id = cursor.getInt(0);
            String taskDescription = cursor.getString(1);
            int done = cursor.getInt(2);
            int order = cursor.getInt(3);
            int rework = cursor.getInt(6);
            String tmStamp = cursor.getString(4);
            String loctn = cursor.getString(5);
            taskItem = new TaskItem(id, taskDescription, done==0 ? false : true, order,rework==0 ? false : true,tmStamp,loctn);

            cursor.close();
        } else {
            taskItem = null;
        }

        db.close();
        return taskItem;
    }

    public String getLocation(Context context) {
        LocationManager manager = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
        Criteria criteria = new Criteria();
        criteria.setAccuracy(Criteria.NO_REQUIREMENT);
        List<String> providers = manager.getProviders(criteria, true);
        List<Location> locations = new ArrayList<Location>();
        for (String provider : providers) {
            Location location = manager.getLastKnownLocation(provider);
            if (location != null && location.getAccuracy()!=0.0) {
                locations.add(location);
            }
        }
        Collections.sort(locations, new Comparator<Location>() {
            @Override
            public int compare(Location location, Location location2) {
                return (int) (location.getAccuracy() - location2.getAccuracy());
            }
        });
        if (locations.size() > 0) {
            Geocoder geocoder = new Geocoder(context, Locale.getDefault());
            List<Address> addresses = null;

            try {
                addresses = geocoder.getFromLocation(
                        locations.get(0).getLatitude(),
                        locations.get(0).getLongitude(),
                        // In this sample, get just a single address.
                        1);
            } catch (IOException ioException) {
                // Catch network or other I/O problems.
                Log.e(TAG, "Service no available", ioException);
            } catch (IllegalArgumentException illegalArgumentException) {
                // Catch invalid latitude or longitude values.
                Log.e(TAG, "Invalid latitude and longitude" + ". " +
                        "Latitude = " + locations.get(0).getLatitude() +
                        ", Longitude = " +
                        locations.get(0).getLongitude(), illegalArgumentException);
            }

            // Handle case where no address was found.
            if (!(addresses == null || addresses.size()  == 0)) {
                Address address = addresses.get(0);
                ArrayList<String> addressFragments = new ArrayList<String>();

                // Fetch the address lines using getAddressLine,
                // join them, and send them to the thread.
                for(int i = 0; i < address.getMaxAddressLineIndex(); i++) {
                    addressFragments.add(address.getAddressLine(i));
                }

                return TextUtils.join(System.getProperty("line.separator"),
                        addressFragments);
            }
        }
        return "";
    }
}
