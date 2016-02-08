package com.funkypanda.backgroundTransfer.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.funkypanda.backgroundTransfer.ANEUtils;
import com.funkypanda.backgroundTransfer.Extension;

import java.io.*;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

// Unzips a file. AIR is buggy and cant save by itself reliably.
public class UnzipFileFunction implements FREFunction
{

    @Override
    public FREObject call(FREContext ctx, FREObject[] args)
    {
        if (args.length != 2) {
            Extension.logError("UnzipFileFunction: Called with " + args.length + " args, needs 2");
            return ANEUtils.booleanAsFREObject(false);
        }
        String pathToZip = ANEUtils.getStringFromFREObject(args[0]);
        String destPath = ANEUtils.getStringFromFREObject(args[1]);

        try
        {
            unzip(new File(pathToZip), new File(destPath));
        }
        catch(IOException e)
        {
            Extension.logError("Failed to unzip " + pathToZip + " " + e.toString() );
            return ANEUtils.booleanAsFREObject(false);
        }
        return  ANEUtils.booleanAsFREObject(true);
    }

    private static void unzip(File zipFile, File targetDirectory) throws IOException {
        ZipInputStream zis = new ZipInputStream(new BufferedInputStream(new FileInputStream(zipFile)));
        try {
            ZipEntry ze;
            int count;
            byte[] buffer = new byte[8192];
            while ((ze = zis.getNextEntry()) != null) {
                File file = new File(targetDirectory, ze.getName());
                File dir = ze.isDirectory() ? file : file.getParentFile();
                if (!dir.isDirectory() && !dir.mkdirs()) {
                    throw new FileNotFoundException("Failed to ensure directory: " + dir.getAbsolutePath());
                }
                if (ze.isDirectory()) {
                    continue;
                }
                FileOutputStream fout = new FileOutputStream(file);
                try {
                    while ((count = zis.read(buffer)) != -1) {
                        fout.write(buffer, 0, count);
                    }
                } finally {
                    fout.close();
                }
            }
        } finally {
            zis.close();
        }
    }

}