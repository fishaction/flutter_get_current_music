package com.example.get_current_music;

import android.annotation.SuppressLint;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private final String CHANNEL = "com.example.methodchannel/interop";
    private final String START_SERVICE = "startService";
    MethodChannel channel;

    private MyBroadcastReceiver mReceiver;
    private IntentFilter intentFilter;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(),CHANNEL);
        channel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
                Log.d("MAIN_ACTIVITY",call.method);
                if(call.method.equals(START_SERVICE)){
                    if(!MediaBrowserService.isRunning(getApplicationContext())){
                        Log.d("MAIN_ACTIVITY","started service");
                        startService(new Intent(MainActivity.this,MediaBrowserService.class));
                    }else{
                        Log.d("MAIN_ACTIVITY","MediaBrowserService is Running");
                    }
                    UpdateReceiver receiver = new UpdateReceiver();
                    IntentFilter filter = new IntentFilter();
                    filter.addAction("UPDATE_ACTION");
                    registerReceiver(receiver,filter);
                }
            }
        });
    }

    protected class UpdateReceiver extends BroadcastReceiver{
        @Override
        public void onReceive(Context context, Intent intent) {
            Bundle extras = intent.getExtras();
            String status = extras.getString("status");
            String musicTitle = "";

            if(extras.get("title") != null){
                Log.d("MAIN_ACTIVITY",(String) extras.getString("title"));
                musicTitle = extras.getString("title");
            }

            channel.invokeMethod(status, musicTitle, new MethodChannel.Result() {
                @Override
                public void success(@Nullable Object result) {

                }

                @Override
                public void error(@NonNull String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {

                }

                @Override
                public void notImplemented() {

                }
            });
        }
    }

    @SuppressLint("HandlerLeak")
    private final Handler updateHandler = new Handler(){
        @Override
        public void handleMessage(@NonNull Message msg) {
            super.handleMessage(msg);
            Bundle bundle = msg.getData();
            String status = bundle.getString("status");
            String musicTitle = "";

            Log.d("MAIN_ACTIVITY",status);
            if(bundle.get("title") != null)
                Log.d("MAIN_ACTIVITY",(String) bundle.getString("title"));

            if(status.equals("onUpdateMusic"))
                musicTitle = bundle.getString("musicTitle");

            channel.invokeMethod(status, "test", new MethodChannel.Result() {
                @Override
                public void success(@Nullable Object result) {
                    Log.d("MAIN_ACTIVITY","success");
                }

                @Override
                public void error(@NonNull String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
                    Log.d("MAIN_ACTIVITY",errorMessage);
                }

                @Override
                public void notImplemented() {
                    Log.d("MAIN_ACTIVITY","notImplemented(status:"+status+")");
                }
            });
        }
    };
}
