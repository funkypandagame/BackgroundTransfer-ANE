package com.ncreated.ane.backgroundtransfer
{

import com.coltware.airxzipANE.ZipEntry;
import com.coltware.airxzipANE.ZipFileReader;

import flash.events.ErrorEvent;
import flash.events.Event;

import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.events.StatusEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.setTimeout;

public class DefaultImplementation extends EventDispatcher {

    private var loaders : Dictionary;

    public function DefaultImplementation() {
        loaders = new Dictionary();
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

                    var loader : ExtendedURLLoader = new ExtendedURLLoader();
                    loader.localPath = localPath;
                    loader.id = sessionId + ":" + remoteURL;
                    loaders[loader.id] = loader;
                    loader.dataFormat = URLLoaderDataFormat.BINARY;
                    loader.addEventListener(ProgressEvent.PROGRESS, onProgress, false, 0, true);
                    loader.addEventListener(Event.COMPLETE, onLoaded, false, 0, true);
                    loader.addEventListener(IOErrorEvent.IO_ERROR, onError, false, 0, true);
                    loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError, false, 0, true);
                    loader.load(new URLRequest(remoteURL));

                }
                break;
            case BTNativeMethods.cancelDownloadTask:
                if (validateParameters(rest, 1)) {
                    var taskId : String = rest[0];
                    if (loaders[taskId]) {
                        var toCancel : ExtendedURLLoader = loaders[taskId];
                        toCancel.removeEventListener(ProgressEvent.PROGRESS, onProgress);
                        toCancel.removeEventListener(Event.COMPLETE, onLoaded);
                        toCancel.removeEventListener(IOErrorEvent.IO_ERROR, onError);
                        toCancel.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
                        toCancel.close();
                        delete loaders[taskId];
                        // Android throws similar looking errors
                        dispatchStatus(escape(taskId) + " Error 1008 Download cancelled", BTInternalMessages.DOWNLOAD_TASK_ERROR);
                    }
                    else {
                        dispatchStatus("Cannot cancel task " + taskId + ", its not loading", BTInternalMessages.ERROR);
                    }
                }
                break;
            case BTNativeMethods.saveFileTask:
                if (validateParameters(rest, 2)) {
                    var path : String = rest[0];
                    var byteArray : ByteArray = rest[1];
                    var f : File = File.applicationStorageDirectory.resolvePath(path);
                    try
                    {
                        var fs : FileStream = new FileStream();
                        fs.open(f, FileMode.WRITE);
                        fs.writeBytes(byteArray);
                        fs.close();
                        return true;
                    }
                    catch (e : Error)
                    {
                        dispatchStatus("Error storing file " + path + " " + e.message, BTInternalMessages.ERROR);
                        return false;
                    }
                }
                break;
            case BTNativeMethods.unZipTask:
                if (validateParameters(rest, 2))
                {
                    var zipFilePath : File = new File(rest[0]);
                    var destPath : File = new File(rest[1]);

                    var outStream : FileStream = new FileStream();
                    var zipReader : ZipFileReader = new ZipFileReader();
                    try {
                        zipReader.open(zipFilePath);
                        var allZipEntries:Vector.<ZipEntry> = zipReader.getEntries();
                        for each (var entry:ZipEntry in allZipEntries)
                        {
                            var fileName:String = entry.getFilename("utf-8");
                            var isDirectory:Boolean = fileName.substr(fileName.length - 1, fileName.length) == "/";
                            var file:File = destPath.resolvePath(entry.getFilename("utf-8"));
                            if (!isDirectory)
                            {
                                var data:ByteArray = zipReader.unzip(entry);
                                outStream.open(file, FileMode.WRITE);
                                outStream.writeBytes(data, 0, data.length);
                                outStream.close();
                            }
                            else if (!file.exists)
                            {
                                file.createDirectory();
                            }
                        }
                        zipReader.close();
                        return true;
                    }
                    catch (err : Error)
                    {
                        dispatchStatus("Error unzipping file " + path + " " + err.message, BTInternalMessages.ERROR);
                        return false;
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
        var item : ExtendedURLLoader = event.target as ExtendedURLLoader;
        var myByteArray : ByteArray = item.data;
        try {
            var fs : FileStream = new FileStream();
            var targetFile : File = new File(item.localPath);
            fs.open(targetFile, FileMode.WRITE);
            fs.writeBytes(myByteArray, 0, myByteArray.length);
            fs.close();
            delete loaders[item.id];
        }
        catch (err: Error) {
            var toReturn : String = escape(item.id) + " Unable to write the file to the disk " + event;
            delete loaders[item.id];
            dispatchStatus(toReturn, BTInternalMessages.DOWNLOAD_TASK_ERROR);
            return;
        }
        dispatchStatus(escape(item.id), BTInternalMessages.DOWNLOAD_TASK_COMPLETED);
    }

    private function onProgress(event: ProgressEvent) : void {
        var item : ExtendedURLLoader = event.target as ExtendedURLLoader;
        var toSend : String = escape(item.id) + " " + event.bytesLoaded + " " + event.bytesTotal;
        dispatchStatus(toSend, BTInternalMessages.DOWNLOAD_TASK_PROGRESS);
    }

    private function onError(event :ErrorEvent) : void {
        var item : ExtendedURLLoader = event.target as ExtendedURLLoader;
        var toReturn : String = escape(item.id) + " " + event;
        delete loaders[item.id];
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
