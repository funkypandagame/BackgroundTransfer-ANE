package com.funkypanda.backgroundTransfer.functions;

import android.net.Uri;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.coolerfall.downloadANE.DownloadCallback;
import com.coolerfall.downloadANE.DownloadRequest;
import com.funkypanda.backgroundTransfer.ANEUtils;
import com.funkypanda.backgroundTransfer.Extension;
import com.funkypanda.backgroundTransfer.FlashConstants;

public class CreateDownloadTaskFunction implements FREFunction
{

    @Override
    public FREObject call(FREContext ctx, FREObject[] args)
    {
        if (args.length != 3) {
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

        DownloadRequest downloadRequest = new DownloadRequest(remoteURL)
                .setProgressInterval(100)
                .setDestFilePath(destPath)
                .setDownloadCallback(new DownloadCallback() {
                    @Override
                    public void onStart(int downloadId, long totalBytes) {
                        Extension.log("Starting download");
                    }

                    @Override
                    public void onRetry(int downloadId) {
                        Extension.log("Retrying download");
                    }

                    @Override
                    public void onProgress(int downloadId, long downloadedBytes, long totalBytes) {
                        String toReturn = getTaskId() + " " + downloadedBytes + " " + totalBytes;
                        Extension.dispatchStatusEventAsync(FlashConstants.DOWNLOAD_TASK_PROGRESS, toReturn, false);
                    }

                    @Override
                    public void onSuccess(int downloadId, String filePath) {
                        Extension.dispatchStatusEventAsync(FlashConstants.DOWNLOAD_TASK_COMPLETED, getTaskId());
                    }

                    @Override
                    public void onFailure(int downloadId, int statusCode, String errorMessage) {
                        String toReturn = getTaskId() + " Error " + statusCode + " " + errorMessage;
                        Extension.dispatchStatusEventAsync(FlashConstants.DOWNLOAD_TASK_ERROR, toReturn);
                    }

                    private String getTaskId() {
                        return ANEUtils.encodeString(Extension.sessionId + ":" + downloadUri.toString());
                    }
                });

        int downloadId = Extension.downloadManager.add(downloadRequest);

        return null;
    }

}