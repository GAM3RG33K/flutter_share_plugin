package com.happyworks.flutter_share_plugin;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.text.TextUtils;
import android.util.Log;
import android.webkit.MimeTypeMap;

import androidx.core.content.FileProvider;

import java.io.File;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterSharePlugin
 */
public class FlutterSharePlugin implements MethodCallHandler {
//    private final static String FILE_PROVIDER_NAME = "FlutterShareFilePathProvider";
    private Registrar mRegistrar;
    private Context mContext;

    private FlutterSharePlugin(Registrar registrar){
        this.mRegistrar = registrar;
        this.mContext = mRegistrar.context();
    }
    /**
     * Plugin registration.
     */
    public static void registerWith(final Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_share_plugin");
        channel.setMethodCallHandler(new FlutterSharePlugin(registrar));
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {

        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        } else if (call.method.equals("share")) {
            share(call, result);
        } else {
            result.notImplemented();
        }
    }

    /**
     * This method will share the contents given in method call parameters
     *
     * @param call   instance of method call class to access the paramters and method name which is called
     * @param result instance of Result which is used to provide the status of the method call to flutter code
     */
    private void share(MethodCall call, Result result) {
        boolean resultStatus = false;

        final String content = call.argument("message");
        final String fileUrl = call.argument("fileUrl");

        if (TextUtils.isEmpty(content) && TextUtils.isEmpty(fileUrl)) {
            final String errorMessage = "Error: Found empty parameters!! At least one Non-empty content id required.";
            Log.e("FlutterShare", errorMessage);
            result.error(errorMessage, null, null);
            return;
        }

        Log.d("FlutterSharePlugin", "Sharing textContent / fileUrl --> " + content + " / " + fileUrl);
        try {

            // create intent to share something to other apps
            // and add flags to clear previous calls
            final Intent intent = new Intent();
            intent.setAction(Intent.ACTION_SEND);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);

            // add extras in the intent
            addExtrasInIntent(intent, content, fileUrl);

            final String title = "Share via...";

            // show chooser UI with share intent and title
            final Intent chooserIntent = Intent.createChooser(intent, title);
            chooserIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            chooserIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            mContext.startActivity(chooserIntent);

            // notify that the process of sharing is successful
            // NOTE: this plugin can only provide functionality upto showing share UI
            resultStatus = true;

        } catch (final Exception ex) {
            Log.e("FlutterShare", "Error: while sharing the contents:", ex);
            result.error("Error: while sharing the contents:", ex.getLocalizedMessage(), null);
        }
        result.success("share successful: " + resultStatus);
    }

    /**
     * This method will add extras flags in intent based on provided content
     *
     * @param intent  source intent, in which the flags will be added
     * @param text    text to be shared, with or without a file
     * @param fileUrl path of the file which is to be shared
     */
    private void addExtrasInIntent(final Intent intent, final String text, final String fileUrl) {
        // check text content status and set it as TEXT
        addTextExtrasInIntent(intent, text);

        // check file uri and set file stream in intent
        addFileExtrasInIntent(intent, fileUrl);
    }

    /**
     * This method will add extras flag related to a file which will be shared
     *
     * @param intent  source intent through which the file will be shared
     * @param fileUrl path of the file
     */
    private void addFileExtrasInIntent(final Intent intent, final String fileUrl) {
        if (!TextUtils.isEmpty(fileUrl)) {
            // Uri fileUri = getFileUri(fileName);
            final Uri fileUri = Uri.parse(fileUrl);
            Log.i("FlutterShare", "file uri--> " + fileUri);

            intent.putExtra(Intent.EXTRA_STREAM, fileUri);
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);

            // set share type as mime type of the file
            String mimeType = getMimeType(fileUri);
            Log.i("FlutterShare", "mimeType--> " + mimeType);
            intent.setType(mimeType);
        }
    }

    /**
     * This method will add the extras flag related to text that is to be shared
     *
     * @param intent source intent through which the text will be shared
     * @param text   text content
     */
    private void addTextExtrasInIntent(final Intent intent, final String text) {
        if (!TextUtils.isEmpty(text)) {
            intent.putExtra(Intent.EXTRA_TEXT, String.copyValueOf(text.toCharArray()));
            // set Share type as text
            intent.setType("text/*");
        }
    }

    private Uri getFileUri(final String fileName) {
        // fetch file from cache storage
        final File file = new File(mContext.getCacheDir(), fileName);
        Log.i("FlutterShare", "getFileUri: file size:" + file.length());

        // get URI from the file
        Uri uriForFile;
        try {
            // get URI using file provider
            uriForFile = FileProvider.getUriForFile(mContext, mContext.getPackageName(), file);
        } catch (final Exception e) {

            Log.e("FlutterShare", "getFileUri: exception while fetching URI using path provider", e);
            // get URI using basic URI parse from the file itself
            uriForFile = Uri.parse(file.getAbsolutePath());
        }
        return uriForFile;
    }

    /**
     * Contents MIME type, this mime type will be used by android OS and other apps
     * to identify which type of content is being shared
     *
     * @param uri file uri
     * @return string containing mime type of the file pointed by given uri
     */
    private String getMimeType(final Uri uri) {
        String mimeType;

        // get file extension
        final String fileExtension = MimeTypeMap.getFileExtensionFromUrl(uri.toString());

        // get mime type from the extension
        mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(fileExtension.toLowerCase());
        return mimeType;
    }
}
