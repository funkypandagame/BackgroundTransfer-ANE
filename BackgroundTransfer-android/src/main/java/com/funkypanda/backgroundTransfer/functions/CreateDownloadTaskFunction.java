package com.funkypanda.backgroundTransfer.functions;

import android.net.Uri;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.funkypanda.backgroundTransfer.ANEUtils;
import com.funkypanda.backgroundTransfer.Extension;
import com.funkypanda.backgroundTransfer.FlashConstants;
import com.thin.downloadmanager.DownloadRequest;
import com.thin.downloadmanager.DownloadStatusListener;

public class CreateDownloadTaskFunction implements FREFunction
{

    @Override
    public FREObject call(FREContext ctx, FREObject[] args)
    {
        if (args.length != 3)
        {
            Extension.logError("CreateDownloadTask: Called with " + args.length + " args, needs 3");
            return null;
        }
        //String sessionId = ANEUtils.getStringFromFREObject(args[0]);
        String remoteURL = ANEUtils.getStringFromFREObject(args[1]);
        String destPath = ANEUtils.getStringFromFREObject(args[2]);

        Extension.log("CreateDownloadTask: Downloading " + remoteURL + " to " + destPath);

        final Uri downloadUri = Uri.parse(remoteURL);
        if (downloadUri == null) {
            Extension.logError("Could not parse download URL " + remoteURL);
            return null;
        }
        else {
            String scheme = downloadUri.getScheme();
            if (scheme == null || (!scheme.equals("http") && !scheme.equals("https"))) {
                Extension.logError("Can only download HTTP/HTTPS URIs: " + downloadUri);
                return null;
            }
        }
        Uri destinationUri = Uri.parse(destPath);
        DownloadRequest downloadRequest = new DownloadRequest(downloadUri)
                .setDestinationURI(destinationUri)
                .setDownloadListener(new DownloadStatusListener() {
                    @Override
                    public void onDownloadComplete(int id) {
                        Extension.dispatchStatusEventAsync(FlashConstants.DOWNLOAD_TASK_COMPLETED, getTaskId());
                    }

                    @Override
                    public void onDownloadFailed(int id, int errorCode, String errorMessage) {
                        String toReturn = getTaskId() + " Error " + errorCode + " " + errorMessage;
                        Extension.dispatchStatusEventAsync(FlashConstants.DOWNLOAD_TASK_ERROR, toReturn);
                    }

                    @Override
                    public void onProgress(int id, long totalBytes, long downloadedBytes, int progress) {
                        String toReturn = getTaskId() + " " + totalBytes + " " + downloadedBytes;
                        Extension.dispatchStatusEventAsync(FlashConstants.DOWNLOAD_TASK_PROGRESS, toReturn);
                    }

                    private String getTaskId() {
                        return ANEUtils.encodeString(Extension.sessionId + ":" + downloadUri.toString());
                    }
                });

        int downloadId = Extension.downloadManager.add(downloadRequest);

        return null;
    }

}