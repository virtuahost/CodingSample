package glassproject.ubicomp.com.todo.model;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class TaskItem{
	private int _id;
	private String _taskdescription;
	private boolean _done;
	private int _order;
    private boolean _rework;
    private String _timestamp;
    private String _loc;
	
	// unused as of now
	private int _urgency; //Now, Tomorrow, Later (0, 1, 2) // perhaps should be an enum
	private int _importance; //high, medium, low (2, 1, 0) // perhaps should be an enum
	private String _deadline;
	private String _tags; //comma-separate list of tags
	
	// transient field; not in db
	public boolean grabbed = false;
	
	public TaskItem(int id, String taskdescription, boolean done, int order,boolean rework,String timestamp,String loc) {
		this._id = id;
		this._taskdescription = taskdescription;
		this._done = done;
		this._order = order;
        this._rework = rework;
        this._timestamp = timestamp;
        this._loc = loc;
	}
	
	public TaskItem(int id, String taskdescription, boolean done) {
		this(id, taskdescription, done, -1,false,"","");
	}
	
	public TaskItem(int id, String taskdescription) {
		this(id, taskdescription, false);
	}
	
	public TaskItem(String string) {
		this(-1, string, false);
	}

	public int getID(){
		return this._id;
	}
	
	public String getTaskDescription(){
		return this._taskdescription;
	}

    public String getTimeStamp(){
        return this._timestamp;
    }

    public String getLoc(){
        return this._loc;
    }
	
	public void updateTaskDescription(String newText){
		this._taskdescription = newText;
	}
	
	public boolean isDone() {
		return _done;
	}
	
	public void markDone(boolean d) {
		_done = d;
	}
	
	public int getOrder() {
		return _order;
	}

    public boolean isRework() { return _rework;}

    public void markRework(boolean r) {
        _rework = r;
    }
	
	public void setOrder(int order) {
		this._order = order;		
	}
	
	// unused as of now
	public int getUrgency(){
		return _urgency;
	}
	
	public int getImportance(){
		return _importance;
	}
	
	public String getDeadline(){
		return _deadline;
	}
	
	public Date getDeadlineAsDateFormat(){
		SimpleDateFormat sdf = new SimpleDateFormat();
		Date d = new Date();
		try {
			d = sdf.parse(_deadline);
		} catch (ParseException e) {
			e.printStackTrace();
		}
		return d;
	}	
	
	public String getTags(){
		return _tags;
	}
	
	public void setTagsBundle(String newTagString){
		this._tags = newTagString;
	}
	
	public void addTag(String newTag){
		String comma = ",";
		String tempStr = comma.concat(newTag);
		this._tags = this._tags.concat(tempStr);
	}
	
	public String toString(TaskItem item){
		return item._taskdescription;
	}
}

