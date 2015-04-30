package glassproject.ubicomp.com.todo.model;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Paint;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import glassproject.ubicomp.com.todo.R;

import static glassproject.ubicomp.com.todo.R.drawable.caution_icon;

public class TaskItemListAdapter extends ArrayAdapter<TaskItem> {

	private final Context context;
	private final TaskItem[] values;

	public TaskItemListAdapter(Context context, TaskItem[] values) {
		super(context, R.layout.task_list_item , values);
		this.context = context;
		this.values = values;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {

		LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		View rowView = inflater.inflate(R.layout.task_list_item, parent, false);
        ImageView cautionView = new ImageView(getContext());
        cautionView.setImageResource(caution_icon);
		TaskItem taskItem = values[position];
		
		TextView tv = (TextView) rowView.findViewById(R.id.taskDescription);		    
		tv.setText(taskItem.getTaskDescription());
		if(taskItem.isDone()) {
			tv.setPaintFlags(tv.getPaintFlags() | Paint.STRIKE_THRU_TEXT_FLAG);
		} else {
			tv.setPaintFlags(tv.getPaintFlags() & (~Paint.STRIKE_THRU_TEXT_FLAG));
		}
		
		if(taskItem.grabbed) {
			rowView.setBackgroundColor(Color.parseColor("#77aa77"));
            if(taskItem.isRework()){
              //  rowView.addView(cautionView);
                tv.setTextColor(Color.parseColor("#FF9036"));
                //rowView.setBackgroundColor(Color.parseColor("#77aa00"));
            }
		}
        else if(taskItem.isRework()){
           // rowView.setBackgroundColor(Color.parseColor("#77aa70"));
           // rowView.addView(cautionView);
           // rowView.setBackgroundColor(Color.parseColor("#77aa00"));
            tv.setTextColor(Color.parseColor("#FF9036"));
        }

		return rowView;
	}
}
