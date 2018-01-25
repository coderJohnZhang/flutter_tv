package com.tcl.flutter.tv;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.BasicMessageChannel;
import io.flutter.plugin.common.JSONMessageCodec;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.view.FlutterMain;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import static android.content.ContentValues.TAG;

public class MainActivity extends FlutterActivity {

    private BasicMessageChannel messageChannel;

    private String[] getArgsFromIntent(Intent intent) {
        // Before adding more entries to this list, consider that arbitrary
        // Android applications can generate intents with extra data and that
        // there are many security-sensitive args in the binary.
        ArrayList<String> args = new ArrayList<String>();
        if (intent.getBooleanExtra("trace-startup", false)) {
            args.add("--trace-startup");
        }
        if (intent.getBooleanExtra("start-paused", false)) {
            args.add("--start-paused");
        }
        if (intent.getBooleanExtra("enable-dart-profiling", false)) {
            args.add("--enable-dart-profiling");
        }
        if (!args.isEmpty()) {
            String[] argsArray = new String[args.size()];
            return args.toArray(argsArray);
        }
        return null;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);
        String[] args = getArgsFromIntent(getIntent());
        FlutterMain.ensureInitializationComplete(getApplicationContext(), args);
        messageChannel = new BasicMessageChannel<>(getFlutterView(), "flutter/keyevent", JSONMessageCodec.INSTANCE);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (event.getRepeatCount() > 0) {
            Log.d(TAG, "onKeyDown: repeatCount > 0.");
            return true;
        }
        Log.d(TAG, "onKeyDown: ACTION_DOWN flags = " + event.getFlags()
                + " codePoint = " + event.getUnicodeChar() + " keyCode = "
                + event.getKeyCode() + " scanCode = " + event.getScanCode() + " metaState = " + event.getMetaState());
        Map<String, Object> maps = new HashMap<>();
        maps.put("flags", event.getFlags());
        maps.put("codePoint", event.getUnicodeChar());
        maps.put("keyCode", event.getKeyCode());
        maps.put("scanCode", event.getScanCode());
        maps.put("metaState", event.getMetaState());
        //messageChannel.send(maps);
        return super.onKeyDown(keyCode, event);
    }
}
