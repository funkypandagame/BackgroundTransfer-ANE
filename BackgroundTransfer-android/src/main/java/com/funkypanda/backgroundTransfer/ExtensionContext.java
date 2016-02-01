package com.funkypanda.backgroundTransfer;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.funkypanda.backgroundTransfer.functions.*;

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

        functionMap.put(FlashConstants.initializeSession, new InitializeSessionFunction());
        functionMap.put(FlashConstants.createDownloadTask, new CreateDownloadTaskFunction());
        functionMap.put(FlashConstants.getDownloadTaskPropertiesArray, new GetDownloadTaskPropertiesFunction());
        functionMap.put(FlashConstants.resumeDownloadTask, new TempFunction());
        functionMap.put(FlashConstants.suspendDownloadTask, new TempFunction());
        functionMap.put(FlashConstants.cancelDownloadTask, new CancelDownloadTaskFunction());
        functionMap.put(FlashConstants.crashTheAppTask, new TempFunction());

        return functionMap;
    }


}