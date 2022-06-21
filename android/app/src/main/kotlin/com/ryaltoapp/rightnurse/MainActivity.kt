package com.ryaltoapp.rightnurse

//import android.os.Bundle
//import io.flutter.embedding.android.FlutterActivity
//import io.flutter.plugin.common.MethodCall
//import io.flutter.plugin.common.MethodChannel
//import io.flutter.plugins.GeneratedPluginRegistrant


import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.plugins.GeneratedPluginRegistrant

import io.flutter.plugin.common.MethodChannel
import com.twilio.audioswitch.AudioDevice;
import com.twilio.audioswitch.AudioSwitch;
import com.twilio.voice.Call;
import com.twilio.voice.CallException;
import com.twilio.voice.CallInvite;
import com.twilio.voice.ConnectOptions;
import com.twilio.voice.RegistrationException;
import com.twilio.voice.RegistrationListener;
import com.twilio.voice.Call.CallQualityWarning;
import com.twilio.voice.Voice;
import android.util.Log
import 	java.util.Locale;


import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.app.NotificationManager;
import android.app.NotificationChannel;
import android.net.Uri;
import android.media.AudioAttributes;
import android.content.ContentResolver;


class MainActivity: FlutterFragmentActivity() {

    private val CHANNEL = "ryalto.com/notification_channel" //The channel name you set in your main.dart file

    private fun createNotificationChannel(mapData: HashMap<String,String>): Boolean {
        val completed: Boolean
        if (VERSION.SDK_INT >= VERSION_CODES.O) {
            // Create the NotificationChannel
            val id = mapData["id"]
            val name = mapData["name"]
            val descriptionText = mapData["description"]
            val sound = "alert.mp3"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val mChannel = NotificationChannel(id, name, importance)
            mChannel.description = descriptionText

            val soundUri = Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE + "://"+ getApplicationContext().getPackageName() + "/raw/alert");
            val att = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                    .build();

            mChannel.setSound(soundUri, att)
            // Register the channel with the system; you can't change the importance
            // or other notification behaviors after this
            val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(mChannel)
            completed = true
        }
        else{
            completed = false
        }
        return completed
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            // Note: this method is invoked on the main thread.
            call, result ->

            if (call.method == "createNotificationChannel"){
                val argData = call.arguments as java.util.HashMap<String, String>
                val completed = createNotificationChannel(argData)
                if (completed == true){
                    result.success(completed)
                }
                else{
                    result.error("Error Code", "Error Message", null)
                }
            } else {
                result.notImplemented()
            }
        }

    }
}


//////////////***********
/*

class MainActivity: FlutterFragmentActivity() {
    override fun configureFlutterEngine( flutterEngine:
                                         FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}


*/


////////////***********

//class MainActivity : FlutterFragmentActivity() {
//    private val CHANNEL = "ryalto.com/twilio"
//    private val TAG = "MainActivity"
//
//
//    /*private fun registrationListener(): RegistrationListener? {
//        return object : RegistrationListener() {
//            @Override
//            fun onRegistered(@NonNull accessToken: String?, @NonNull fcmToken: String) {
//                Log.d(TAG, "Successfully registered FCM $fcmToken")
//            }
//
//            @Override
//            fun onError(@NonNull error: RegistrationException,
//                        @NonNull accessToken: String?,
//                        @NonNull fcmToken: String?) {
//                val message: String = String.format(
//                        Locale.US,
//                        "Registration Error: %d, %s",
//                        error.getErrorCode(),
//                        error.getMessage())
//                Log.e(TAG, message)
//                Snackbar.make(coordinatorLayout, message, Snackbar.LENGTH_LONG).show()
//            }
//        }
//    }
//
//    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
//            if (call.method == "callTwilio") {
//                executeTwilioVoiceCall()
//                result.success("Hello from Android")
//            } else {
//                result.notImplemented()
//            }
//        }
//        GeneratedPluginRegistrant.registerWith(flutterEngine)
//    }
//
//    private val accessToken = ""
//    var params = HashMap<String, String>()
//    var callListener: Call.Listener = callListener()
//    fun executeTwilioVoiceCall(){
//        val connectOptions = ConnectOptions.Builder(accessToken)
//                .params(params)
//                .build()
//        Voice.connect(this, connectOptions, callListener)
//    }
//
//    private fun callListener(): Call.Listener {
//        return object : Call.Listener {
//            override fun onRinging(call: Call) {
//                Log.d(TAG, "Ringing")
//            }
//
//            override fun onConnectFailure(call: Call, error: CallException) {
//                Log.d(TAG, "Connect failure")
//            }
//
//            override fun onConnected(call: Call) {
//                Log.d(TAG, "Connected")
//            }
//
//            override fun onReconnecting(call: Call, callException: CallException) {
//                Log.d(TAG, "onReconnecting")
//            }
//
//            override fun onReconnected(call: Call) {
//                Log.d(TAG, "onReconnected")
//            }
//
//            override fun onDisconnected(call: Call, error: CallException?) {
//                Log.d(TAG, "Disconnected")
//            }
//
//            override fun onCallQualityWarningsChanged(call: Call,
//                                                      currentWarnings: MutableSet<CallQualityWarning>,
//                                                      previousWarnings: MutableSet<CallQualityWarning>) {
//                if (previousWarnings.size > 1) {
//                    val intersection: MutableSet<CallQualityWarning> = HashSet(currentWarnings)
//                    currentWarnings.removeAll(previousWarnings)
//                    intersection.retainAll(previousWarnings)
//                    previousWarnings.removeAll(intersection)
//                }
//                val message = String.format(
//                        Locale.US,
//                        "Newly raised warnings: $currentWarnings Clear warnings $previousWarnings")
//                Log.e(TAG, message)
//            }
//        }
//    }
//}
