package com.tcl.flutter.tv;

import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    private static final String TAG = MainActivity.class.getName();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (event.getRepeatCount() > 0) {
            Log.d(TAG, "onKeyDown: repeatCount > 0.");
            return true;
        }
        Log.d(TAG, "onKeyDown: ACTION_DOWN flags = " + event.getFlags()
                + " codePoint = " + event.getUnicodeChar() + " keyCode = "
                + event.getKeyCode() + " scanCode = " + event.getScanCode()
                + " metaState = " + event.getMetaState());
        return super.onKeyDown(keyCode, event);
    }
}
