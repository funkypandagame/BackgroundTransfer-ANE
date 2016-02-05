package com.funkypanda.backgroundTransfer;

import android.app.Activity;
import android.util.Log;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;
import com.coolerfall.downloadANE.DownloadManager;

public class Extension implements FREExtension
{
    private static final String TAG = "AirBackgroundTransfer";

    public static String sessionId;

    private static ExtensionContext context;

    public static DownloadManager downloadManager;

    public static void dispatchStatusEventAsync(String eventCode, String message)
    {
        if (context != null) {
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
            downloadManager = null;
        }
        // after calling this dispose() the library will not be usable!
        context = null;
    }

    public void initialize() {
        downloadManager = new DownloadManager();
    }

    public static void log(String message)
    {
        Log.d(TAG, message);
        if (context != null) {
            context.dispatchStatusEventAsync(message, FlashConstants.DEBUG_LOG);
        }
    }

    public static void logError(String message)
    {
        Log.e(TAG, message);
        if (context != null) {
            context.dispatchStatusEventAsync(message, FlashConstants.ERROR);
        }
    }
}