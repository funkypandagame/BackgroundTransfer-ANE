package com.funkypanda.backgroundTransfer.functions;

import android.os.AsyncTask;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.funkypanda.backgroundTransfer.ANEUtils;
import com.funkypanda.backgroundTransfer.Extension;
import com.funkypanda.backgroundTransfer.FlashConstants;
import net.lingala.zip4j.core.ZipFile;
import net.lingala.zip4j.exception.ZipException;
import net.lingala.zip4j.progress.ProgressMonitor;

// Unzips a file.
public class UnzipFileFunction implements FREFunction
{

    @Override
    public FREObject call(FREContext ctx, FREObject[] args)
    {
        if (args.length != 2) {
            Extension.dispatchStatusEventAsync(FlashConstants.UNZIP_ERROR, "UnzipFileFunction: Called with " + args.length + " args, needs 2");
            return null;
        }
        String pathToZip = ANEUtils.getStringFromFREObject(args[0]);
        String destPath = ANEUtils.getStringFromFREObject(args[1]);
        new ExtractTask().execute(pathToZip, destPath);
        return null;
    }

    private class ExtractTask extends AsyncTask<String, Integer, String> {

        @Override
        protected String doInBackground(String... params) {
            String pathToZip = params[0];
            String destPath = params[1];

            try
            {
                ZipFile zipFile = new ZipFile(pathToZip);
                ProgressMonitor pm = zipFile.getProgressMonitor();
                zipFile.setRunInThread(true);
                zipFile.extractAll(destPath);
                while (pm.getPercentDone() < 100)
                {
                    publishProgress(pm.getPercentDone());
                    try {
                        Thread.sleep(200);
                    } catch (InterruptedException e) {
                        zipFile.getProgressMonitor().cancelAllTasks();
                        return "Failed to unzip " + pathToZip + " " + e.toString();
                    }
                }
            }
            catch (ZipException e) {
                return "Failed to unzip " + pathToZip + " " + e.toString();
            }
            return "";
        }

        @Override
        protected void onPostExecute(String result) {
            if (result.equals("")) {
                Extension.dispatchStatusEventAsync(FlashConstants.UNZIP_COMPLETE, "");
            }
            else {
                Extension.dispatchStatusEventAsync(FlashConstants.UNZIP_ERROR, result);
            }
        }

        @Override
        protected void onProgressUpdate(Integer... values) {
            Extension.dispatchStatusEventAsync(FlashConstants.UNZIP_PROGRESS, values[0].toString());
        }
    }

}