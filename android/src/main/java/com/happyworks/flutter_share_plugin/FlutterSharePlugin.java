package com.happyworks.flutter_share_plugin;

import java.lang.reflect.Field;

import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterSharePlugin
 */
public class FlutterSharePlugin implements MethodCallHandler {
    private static Registrar mRegistrar;

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        mRegistrar = registrar;
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_share_plugin");
        channel.setMethodCallHandler(new FlutterSharePlugin());
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("share")) {

            boolean resultStatus = false;

            String content = call.argument("content");
            // String message = call.argument("message");
            String fileUrl = call.argument("fileUrl");

            if ((content == null && fileUrl == null) || (content.isEmpty() && fileUrl.isEmpty())) {
                Log.println(Log.ERROR, "FlutterShare",
                        "Error: Found empty parameters!! At least one Non-empty content id required.");
                return;
            }

            Log.println(Log.INFO, "FlutterShare", "Sharing textContent / file --> " + content + " / " + fileUrl);
            try {

                // create intent to share something to other apps
                // and add flags to clear previous calls
                Intent intent = new Intent();
                intent.setAction(Intent.ACTION_SEND);
                intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                // set share type as all (*)
                intent.setType("*/*");

                // check file url and fetch file
                if (fileUrl != null && !fileUrl.isEmpty()) {
                    Uri fileUri = Uri.parse(fileUrl);
                    intent.putExtra(Intent.EXTRA_STREAM, fileUri);
                    intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                }

                // check text content status and set it as TEXT or SUBJECT accordingly
                if (content != null && !content.isEmpty()) {

                    // if the String content shared has less than 60 characters than set it as
                    // subject.
                    if (content.length() <= 60) {
                        intent.putExtra(Intent.EXTRA_SUBJECT, String.copyValueOf(content.toCharArray()));
                    }
                    intent.putExtra(Intent.EXTRA_TEXT, String.copyValueOf(content.toCharArray()));
                }

                // set content as title of the share dialog
                content = "Share with...";

                // show chooser UI with share intent and title
                Intent chooserIntent = Intent.createChooser(intent, content);
                chooserIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                chooserIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                mRegistrar.context().startActivity(chooserIntent);

                // notify that the process of sharing is successful
                // NOTE: this plugin can only provide functionality upto showing share UI
                resultStatus = true;

            } catch (Exception ex) {
                Log.println(Log.ERROR, "FlutterShare", "Error: while sharing the contents:" + ex);
            }
            result.success(resultStatus);
        } else {
            result.notImplemented();
        }
    }
}
