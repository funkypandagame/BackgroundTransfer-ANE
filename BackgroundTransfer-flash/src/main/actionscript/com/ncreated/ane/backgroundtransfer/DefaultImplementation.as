package com.ncreated.ane.backgroundtransfer
{
import br.com.stimuli.loadingANE.BulkLoader;
import br.com.stimuli.loadingANE.BulkProgressEvent;
import br.com.stimuli.loadingANE.loadingtypes.LoadingItem;

import flash.events.ErrorEvent;
import flash.events.Event;

import flash.events.EventDispatcher;
import flash.events.StatusEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;
import flash.utils.setTimeout;

public class DefaultImplementation extends EventDispatcher {

    private var loader : BulkLoader;

    public static const INTERNAL_LOADER_NAME : String = "usedByAneName";

    public function DefaultImplementation() {
        loader = new BulkLoader(INTERNAL_LOADER_NAME);
    }

    public function call(functionName:String,... rest):Object {
        switch (functionName) {
            case BTNativeMethods.initializeSession:

                    if (validateParameters(rest, 1)) {
                        var sessionData : String = rest[0] + " ";
                        dispatchStatus("WARNING: Using default loader implementation. This should only happen on PC.", BTInternalMessages.DEBUG_LOG);
                        dispatchStatus(sessionData, BTInternalMessages.SESSION_INITIALIZED);
                    }
                break;
            case BTNativeMethods.createDownloadTask:
                if (validateParameters(rest, 3)) {
                    var sessionId : String = rest[0];
                    var remoteURL : String = rest[1];
                    var localPath : String = rest[2];//it needs to remember this!
                    var li : LoadingItem = loader.add(remoteURL, {id:sessionId + ":" + remoteURL, type:BulkLoader.TYPE_BINARY});
                    li.extraData = localPath;
                    li.addEventListener(Event.COMPLETE, onLoaded);
                    li.addEventListener(BulkLoader.PROGRESS, onProgress);
                    li.addEventListener(BulkLoader.ERROR, onError);
                    loader.start();
                }
                break;
            case BTNativeMethods.cancelDownloadTask:
                if (validateParameters(rest, 1)) {
                    var taskId : String = rest[0];
                    if (loader.remove(taskId)) {
                        dispatchStatus("Task " + taskId + " cancelled.", BTInternalMessages.DEBUG_LOG);
                    }
                    else {
                        dispatchStatus("Cannot cancel task " + taskId + ", its not loading", BTInternalMessages.ERROR);
                    }
                }
                break;
            default:
                    BackgroundTransfer.instance.dispatchEvent(new BTDebugEvent(functionName + " not implemented in this platform"));
                break;
        }
        return null;
    }


    private function onLoaded(event: Event) : void {
        var item : LoadingItem = event.target as LoadingItem;
        var myByteArray : ByteArray = loader.getBinary(item.id);
        try {
            var fs : FileStream = new FileStream();
            var targetFile : File = new File(item.extraData as String);
            fs.open(targetFile, FileMode.WRITE);
            fs.writeBytes(myByteArray, 0, myByteArray.length);
            fs.close();
            loader.remove(item.id);
        }
        catch (err: Error) {
            var toReturn : String = escape(item.id) + " Unable to write the file to the disk " + event;
            loader.remove(item.id);
            dispatchStatus(toReturn, BTInternalMessages.DOWNLOAD_TASK_ERROR);
            return;
        }
        dispatchStatus(escape(item.id), BTInternalMessages.DOWNLOAD_TASK_COMPLETED);
    }

    private function onProgress(event: BulkProgressEvent) : void {
        var item : LoadingItem = event.target as LoadingItem;
        var toSend : String = escape(item.id) + " " + event.bytesLoaded + " " + event.bytesTotal;
        dispatchStatus(toSend, BTInternalMessages.DOWNLOAD_TASK_PROGRESS);
    }

    private function onError(event :ErrorEvent) : void {
        var item : LoadingItem = event.target as LoadingItem;
        var toReturn : String = escape(item.id) + " Error " + event;
        loader.remove(item.id);
        dispatchStatus(toReturn,  BTInternalMessages.DOWNLOAD_TASK_ERROR);
    }

    private function dispatchStatus(code: String, level : String) : void
    {
        setTimeout(function():void
        {
            dispatchEvent(new StatusEvent(StatusEvent.STATUS, false, false, code, level));
        }, 10);
    }

    private function validateParameters(args : Array, needed : uint) : Boolean {
        if (!args || args.length != needed) {
            dispatchStatus("Wrong number of parameters", BTInternalMessages.ERROR);
            return false;
        }
        return true;
    }
}
}
