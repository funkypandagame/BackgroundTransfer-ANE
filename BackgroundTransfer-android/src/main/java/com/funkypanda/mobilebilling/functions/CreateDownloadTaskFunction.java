package com.funkypanda.mobilebilling.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.funkypanda.mobilebilling.ANEUtils;
import com.funkypanda.mobilebilling.Extension;

public class CreateDownloadTaskFunction implements FREFunction
{

    @Override
    public FREObject call(FREContext ctx, FREObject[] args)
    {
        // Receipt is the token property in Android
        final String receipt = ANEUtils.getStringFromFREObject(args[0]);

        Extension.log("Starting consume with receipt " + receipt);

        return null;
    }

}