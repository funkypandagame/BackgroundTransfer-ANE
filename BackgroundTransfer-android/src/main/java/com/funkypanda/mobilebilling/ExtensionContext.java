package com.funkypanda.mobilebilling;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.funkypanda.mobilebilling.functions.*;

import java.util.HashMap;
import java.util.Map;

public class ExtensionContext extends FREContext
{
    public ExtensionContext() {}

    @Override
    public void dispose() {}

    @Override
    public Map<String, FREFunction> getFunctions()
    {
        Map<String, FREFunction> functionMap = new HashMap<String, FREFunction>();

        functionMap.put(FlashConstants.initializeSession, new CreateDownloadTaskFunction());
        functionMap.put(FlashConstants.createDownloadTask, new CreateDownloadTaskFunction());
        functionMap.put(FlashConstants.getDownloadTaskPropertiesArray, new CreateDownloadTaskFunction());
        functionMap.put(FlashConstants.resumeDownloadTask, new CreateDownloadTaskFunction());
        functionMap.put(FlashConstants.suspendDownloadTask, new CreateDownloadTaskFunction());
        functionMap.put(FlashConstants.cancelDownloadTask, new CreateDownloadTaskFunction());
        functionMap.put(FlashConstants.crashTheAppTask, new CreateDownloadTaskFunction());

        return functionMap;
    }


}