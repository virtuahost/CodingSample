package glassproject.ubicomp.com.todo.activity;

import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;
import android.widget.TextView;

import com.google.android.glass.touchpad.Gesture;
import com.google.android.glass.touchpad.GestureDetector;

/**
 * Created by Deep on 3/9/2015.
 */
public class TextViewGestureDetector extends TextView
        implements View.OnAttachStateChangeListener {

    private final GestureDetector mTouchDetector;
    public NewTaskActivity objActivity;

    public TextViewGestureDetector(Context context, AttributeSet attrs) {
        super(context, attrs);
        mTouchDetector = createGestureDetector(context);
        // must set the view to be focusable
        setFocusable(true);
        setFocusableInTouchMode(true);
    }

    public TextViewGestureDetector(Context context) {
        this(context, null);
    }

    @Override
    public void onViewAttachedToWindow(View v) {
        requestFocus();
    }

    @Override
    public void onViewDetachedFromWindow(View v) {
    }

    /**
     * Pass a MotionEvent into the gesture detector
     */
    @Override
    public boolean dispatchGenericFocusedEvent(MotionEvent event) {
        if (isFocused()) {
            return mTouchDetector.onMotionEvent(event);
        }
        return super.dispatchGenericFocusedEvent(event);
    }

    /**
     * Create gesture detector that triggers onClickListener. Implement
     * onClickListener in your Activity and override
     * onClick() to handle the "tap" gesture.
     */
    private GestureDetector createGestureDetector(Context context) {
        GestureDetector gd = new GestureDetector(context);
        gd.setBaseListener(new GestureDetector.BaseListener() {

            @Override
            public boolean onGesture(Gesture gesture) {
                if (gesture == Gesture.SWIPE_DOWN) {
                    objActivity.saveTask();
                }
                return false;
            }
        });
        return gd;
    }
}
