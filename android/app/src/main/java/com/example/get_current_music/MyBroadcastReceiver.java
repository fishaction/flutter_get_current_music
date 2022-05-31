package com.example.get_current_music;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

public class MyBroadcastReceiver extends BroadcastReceiver {

    public static Handler handler;

    @Override
    public void onReceive(Context context, Intent intent) {
        Bundle bundle = intent.getExtras();
        String message = bundle.getString("status");
        if(handler != null){
            Message msg = new Message();
            Bundle data = new Bundle();
            data.putString("status",message);
            msg.setData(data);
            handler.sendMessage(msg);
        }
    }
    public void registerHandler(Handler _handler){
        handler = _handler;
    }
}