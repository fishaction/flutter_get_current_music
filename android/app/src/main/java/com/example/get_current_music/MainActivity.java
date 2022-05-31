package com.example.get_current_music;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.Handler;
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
                if(call.method.equals(START_SERVICE)){
                    mReceiver = new MyBroadcastReceiver();
                    intentFilter = new IntentFilter();
                    intentFilter.addAction("UPDATE_ACTION");
                    registerReceiver(mReceiver,intentFilter);

                    mReceiver.registerHandler(updateHandler);

                    startService(new Intent(MainActivity.this,MediaAppControllerService.class));
                }
            }
        });
    }

    @SuppressLint("HandlerLeak")
    private Handler updateHandler = new Handler(){
        @Override
        public void handleMessage(@NonNull Message msg) {
            super.handleMessage(msg);
            Bundle bundle = msg.getData();
            String status = bundle.getString("status");
            channel.invokeMethod(status, null, new MethodChannel.Result() {
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
