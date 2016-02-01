package com.funkypanda.backgroundTransfer;

import android.app.Activity;
import android.util.Log;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;
import com.thin.downloadmanager.ThinDownloadManager;

public class Extension implements FREExtension
{
    private static final String TAG = "AirBackgroundTransfer";

    public static String sessionId;

    private static ExtensionContext context;

    public static ThinDownloadManager downloadManager;

    public static void dispatchStatusEventAsync(String eventCode, String message)
    {
        if (context != null) {
            Log.d(TAG, message + " " + eventCode);
            context.dispatchStatusEventAsync(message, eventCode);
        }
        else {
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
        if (downloadManager != null) {
            downloadManager.release();
        }
        // after calling this dispose() the library will not be usable!
        context = null;
    }

    public void initialize() {
        downloadManager = new ThinDownloadManager();
    }

    public static void log(String message)
    {
        Log.d(TAG, message);
        context.dispatchStatusEventAsync(message, FlashConstants.DEBUG_LOG);
    }

    public static void logError(String message)
    {
        Log.e(TAG, message);
        context.dispatchStatusEventAsync(message, FlashConstants.ERROR);
    }
}