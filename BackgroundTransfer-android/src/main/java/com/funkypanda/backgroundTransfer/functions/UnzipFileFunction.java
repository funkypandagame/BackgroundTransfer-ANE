package com.funkypanda.backgroundTransfer.functions;

import com.adobe.fre.FREByteArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.funkypanda.backgroundTransfer.ANEUtils;
import com.funkypanda.backgroundTransfer.Extension;

import java.io.*;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

// Saves a file to the disk. AIR is buggy and cant save by itself reliably.
// Since the file is kept in the memory the whole time do not use it with large files!
public class UnzipFileFunction implements FREFunction
{

    @Override
    public FREObject call(FREContext ctx, FREObject[] args)
    {
        if (args.length != 1) {
            Extension.logError("UnzipFileFunction: Called with " + args.length + " args, needs 1");
            return ANEUtils.booleanAsFREObject(false);
        }
        String pathToZip = ANEUtils.getStringFromFREObject(args[0]);

        InputStream is;
        ZipInputStream zis;
        try
        {
            is = new FileInputStream(pathToZip);
            zis = new ZipInputStream(new BufferedInputStream(is));
            ZipEntry ze;
            byte[] buffer = new byte[1024];
            int count;

            while ((ze = zis.getNextEntry()) != null)
            {
                // Need to create directories if not exists, or
                // it will generate an Exception...
                if (ze.isDirectory()) {
                    File fmd = new File(pathToZip);
                    fmd.mkdirs();
                    continue;
                }
                FileOutputStream fout = new FileOutputStream(pathToZip);
                while ((count = zis.read(buffer)) != -1)
                {
                    fout.write(buffer, 0, count);
                }
                fout.close();
                zis.closeEntry();
            }
            zis.close();
        }
        catch(IOException e)
        {
            Extension.logError("Failed to unzip " + pathToZip + " " + e.toString() );
            return ANEUtils.booleanAsFREObject(false);
        }
        return  ANEUtils.booleanAsFREObject(true);
    }

}