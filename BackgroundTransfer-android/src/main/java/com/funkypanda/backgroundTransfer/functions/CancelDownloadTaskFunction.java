package com.funkypanda.backgroundTransfer.functions;

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.funkypanda.backgroundTransfer.ANEUtils;
import com.funkypanda.backgroundTransfer.Extension;

public class CancelDownloadTaskFunction implements FREFunction
{

    @Override
    public FREArray call(FREContext ctx, FREObject[] args)
    {
        if (args.length != 1)
        {
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

        int result = Extension.downloadManager.cancel(taskURL);
        if (result == 0) {
            Extension.logError("Failed to cancel download with URL " + taskURL);
        }

        return null;
    }

}