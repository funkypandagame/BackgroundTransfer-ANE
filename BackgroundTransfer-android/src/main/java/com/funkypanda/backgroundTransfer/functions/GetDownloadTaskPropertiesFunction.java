package com.funkypanda.backgroundTransfer.functions;

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.funkypanda.backgroundTransfer.Extension;

// In the iOS implementation this is called based on what the initialize function returns.
// The Android implementation does nothing since it cant keep downloads between sessions.
public class GetDownloadTaskPropertiesFunction implements FREFunction
{

    @Override
    public FREArray call(FREContext ctx, FREObject[] args)
    {
        if (args.length != 1)
        {
            Extension.logError("GetDownloadTaskProperties: Called with " + args.length + " args, needs 1");
            return null;
        }

        return null;
    }

}