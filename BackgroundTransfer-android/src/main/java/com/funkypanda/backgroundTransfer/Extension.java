package com.funkypanda.backgroundTransfer;

import android.app.Activity;
import android.util.Log;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

public class Extension implements FREExtension
{
    private static final String TAG = "AirBackgroundTransfer";

    private static ExtensionContext context;

    public static void dispatchStatusEventAsync(String eventCode, String message)
    {
        if (context != null)
        {
            log(eventCode + " " + message);
            context.dispatchStatusEventAsync(message, eventCode);
        }
        else
        {
            Log.e(TAG, "Extension context is null, was the extension disposed? Tried to send event " +
                 eventCode + " with message " + message);
        }
    }

    public static Activity getActivity()
    {
        return context.getActivity();
    }

    // Called automatically from Flash: ExtensionContext.createExtensionContext()
    public FREContext createContext(String extId)
    {
        return context = new ExtensionContext();
    }

    public void dispose()
    {
        // after calling this dispose() the library will not be usable!
        context = null;
    }

    public void initialize() {}

    public static void log(String message)
    {
        Log.d(TAG, message);
        context.dispatchStatusEventAsync(message, FlashConstants.DEBUG_LOG);
    }

    public static void logError(String message)
    {
        Log.e(TAG, message);
        context.dispatchStatusEventAsync(message, FlashConstants.ERROR);
        /*
        this code goes to download task error
        String encodedMsg = "";
        try {
            encodedMsg = URLEncoder.encode(message, "utf-8");
        } catch (UnsupportedEncodingException e) {
            encodedMsg = "URLEncoder_Error";
        }
        encodedMsg = taskId + " " + encodedMsg;
        Log.e(TAG, taskId + " " + message);
        context.dispatchStatusEventAsync(encodedMsg, FlashConstants.DOWNLOAD_TASK_ERROR);
        */
    }
}