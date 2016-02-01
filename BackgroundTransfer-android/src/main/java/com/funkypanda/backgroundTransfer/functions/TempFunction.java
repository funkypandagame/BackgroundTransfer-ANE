package com.funkypanda.backgroundTransfer.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.funkypanda.backgroundTransfer.Extension;

public class TempFunction implements FREFunction
{

    @Override
    public FREObject call(FREContext ctx, FREObject[] args)
    {
        Extension.log("Called tempFunction with " + args.length + " args");

        return null;
    }

}