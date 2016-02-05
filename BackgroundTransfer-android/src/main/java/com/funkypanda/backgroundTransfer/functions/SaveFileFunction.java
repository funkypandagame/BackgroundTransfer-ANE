package com.funkypanda.backgroundTransfer.functions;

import com.adobe.fre.*;
import com.funkypanda.backgroundTransfer.ANEUtils;
import com.funkypanda.backgroundTransfer.Extension;

import java.io.File;
import java.io.FileOutputStream;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;

// Saves a file to the disk. AIR is buggy and cant save by itself reliably.
// Since the file is kept in the memory the whole time do not use it with large files!
public class SaveFileFunction implements FREFunction
{

    @Override
    public FREObject call(FREContext ctx, FREObject[] args)
    {
        if (args.length != 2) {
            Extension.logError("SaveFileFunction: Called with " + args.length + " args, needs 2");
            return ANEUtils.booleanAsFREObject(false);
        }
        String pathToSave = ANEUtils.getStringFromFREObject(args[0]);
        FREByteArray byteArray = (FREByteArray) args[1];

        try {
            byteArray.acquire();
            ByteBuffer byteBuffer = byteArray.getBytes();
            byte bytes[] = new byte[byteBuffer.limit()];
            byteBuffer.get(bytes);
            byteArray.release();

            File file = new File(pathToSave);
            FileChannel channel = new FileOutputStream(file, false).getChannel();
            // Flips this buffer. The limit is set to the current position and then
            // the position is set to zero  If the mark is defined then it is discarded.
            byteBuffer.flip();
            channel.write(byteBuffer);
            channel.close();
            return ANEUtils.booleanAsFREObject(true);

        } catch (Exception e) {
            Extension.logError("Unable to write file " + pathToSave + " " + e.toString());
        }
        return ANEUtils.booleanAsFREObject(false);
    }


}