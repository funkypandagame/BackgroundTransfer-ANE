package com.funkypanda.backgroundTransfer.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.funkypanda.backgroundTransfer.ANEUtils;
import com.funkypanda.backgroundTransfer.Extension;
import com.funkypanda.backgroundTransfer.FlashConstants;

// The Android implementation does nothing since it cant keep downloads between sessions
public class InitializeSessionFunction implements FREFunction
{

    @Override
    public FREObject call(FREContext ctx, FREObject[] args)
    {
        if (args.length != 1)
        {
            Extension.logError("InitializeSession: Called with " + args.length + " args, needs 1");
            return null;
        }
        // This is actually not used for anything, its the iOS implementation needs it.
        Extension.sessionId = ANEUtils.getStringFromFREObject(args[0]);
        String toReturn = Extension.sessionId + " ";
        Extension.log("called InitializeSession with session Id " + Extension.sessionId);

        // sends "sessionId urlEncodedURL1 urlEncodedURL2 urlEncodedURL3 urlEncodedURL4"
        Extension.dispatchStatusEventAsync(FlashConstants.SESSION_INITIALIZED, toReturn);
        return null;
    }

}