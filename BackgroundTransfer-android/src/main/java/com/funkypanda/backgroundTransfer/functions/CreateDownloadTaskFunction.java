package com.funkypanda.backgroundTransfer.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.funkypanda.backgroundTransfer.Extension;

public class CreateDownloadTaskFunction implements FREFunction
{

    @Override
    public FREObject call(FREContext ctx, FREObject[] args)
    {
        Extension.logError("ERR CreateDownloadTask: Called with " + args.length + " args, needs 3");
        Extension.log("DEBUG CreateDownloadTask: Called with " + args.length + " args");
        return null;
        /*
        if (args.length != 3)
        {
            Extension.logError("-1", "CreateDownloadTask: Called with " + args.length + " args, needs 3");
            return null;
        }
        //final List<String> params = ANEUtils.getListOfStringFromFREArray((FREArray)args);

        return null;*/
    }

}