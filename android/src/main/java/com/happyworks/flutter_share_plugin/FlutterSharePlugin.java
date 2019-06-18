package com.happyworks.flutter_share_plugin;

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
            boolean status = false;
            String content = call.argument("content");
            //String message = call.argument("message");
            String fileUrl = call.argument("fileUrl");

            try {
				Uri fileUri = Uri.parse(fileUrl);

                Intent intent = new Intent();
                intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                intent.setAction(Intent.ACTION_SEND);
                intent.setType("*/*");
                
                if (fileUrl != null && fileUrl != "") {
					intent.putExtra(Intent.EXTRA_STREAM, fileUri);
					intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
				} else {
					Log.println(Log.INFO, "", "FlutterShare: ShareLocalFile Warning: fileUrl null or empty");
                    //return;
                    intent.putExtra(Intent.EXTRA_SUBJECT, String.copyValueOf(content.toCharArray()));
                    content = "Share with";
				}

                Intent chooserIntent = Intent.createChooser(intent, content);
                chooserIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                chooserIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                mRegistrar.context().startActivity(chooserIntent);
                status = true;
            } catch (Exception ex) {
                Log.println(Log.INFO, "", "FlutterSharePlugin: Error");
            }
            result.success(status);
        } else {
            result.notImplemented();
        }
    }
}
