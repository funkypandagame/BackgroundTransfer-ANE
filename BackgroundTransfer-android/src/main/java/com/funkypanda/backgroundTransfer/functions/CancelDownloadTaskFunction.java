package com.funkypanda.backgroundTransfer.functions;

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.funkypanda.backgroundTransfer.ANEUtils;
import com.funkypanda.backgroundTransfer.Extension;
import com.funkypanda.backgroundTransfer.FlashConstants;

public class CancelDownloadTaskFunction implements FREFunction
{

    @Override
    public FREArray call(FREContext ctx, FREObject[] args)
    {
        if (args.length != 1) {
            Extension.logError("CancelDownloadTaskFunction: Called with " + args.length + " args, needs 1");
            return null;
        }
        String taskId = ANEUtils.getStringFromFREObject(args[0]);
        // looks like sessionID + ":"+ _remoteURL;
        int numToCut = Extension.sessionId.length() + 1;
        if (taskId == null || taskId.length() < numToCut + 4) {
            Extension.logError("CancelDownloadTaskFunction: Wrong task Id " + taskId);
            return null;
        }
        String taskURL = taskId.substring(numToCut);

        boolean result = Extension.downloadManager.cancel(taskURL);
        if (!result) {
            Extension.logError("Failed to cancel download with URL " + taskURL);
        }
        else {
            Extension.log("Cancelled download with URL " + taskURL);
            String toReturn = ANEUtils.encodeString(Extension.sessionId + ":" + taskURL) + " Error 1008 Download cancelled";
            Extension.dispatchStatusEventAsync(FlashConstants.DOWNLOAD_TASK_ERROR, toReturn);
        }
        return null;
    }

}