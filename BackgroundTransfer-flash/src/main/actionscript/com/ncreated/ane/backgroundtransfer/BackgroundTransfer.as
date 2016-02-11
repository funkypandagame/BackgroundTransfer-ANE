package com.ncreated.ane.backgroundtransfer {

import com.ncreated.ane.backgroundtransfer.events.BTDebugEvent;
import com.ncreated.ane.backgroundtransfer.events.BTErrorEvent;
import com.ncreated.ane.backgroundtransfer.events.BTSessionInitializedEvent;
import com.ncreated.ane.backgroundtransfer.events.BTUnzipCompletedEvent;
import com.ncreated.ane.backgroundtransfer.events.BTUnzipErrorEvent;
import com.ncreated.ane.backgroundtransfer.events.BTUnzipProgressEvent;

import flash.events.EventDispatcher;
import flash.events.StatusEvent;
import flash.external.ExtensionContext;
import flash.filesystem.File;
import flash.system.Capabilities;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

public class BackgroundTransfer extends EventDispatcher {

    private static const EXTENSION_ID:String = "com.funkypanda.backgroundTransfer";
    private static var _instance:BackgroundTransfer;
    private var _extensionContext:Object;
    private var _downloadTasks:Dictionary;
    private var _initializedSessions:Array;

    public static function get instance():BackgroundTransfer {
        if (!_instance) {
            _instance = new BackgroundTransfer();
        }
        return _instance;
    }

    public function BackgroundTransfer() {
        if (!_extensionContext) {
            if (Capabilities.manufacturer.indexOf("iOS") > -1 || Capabilities.manufacturer.indexOf("Android") > -1) {
                try {
                    _extensionContext = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
                }
                catch (e:Error) {
                    trace("BackgroundTransfer ANE context creation failed.");
                }
            }
            else {
                _extensionContext = new DefaultImplementation();
            }
            _extensionContext.addEventListener(StatusEvent.STATUS, onStatusEvent);
            _downloadTasks = new Dictionary();
            _initializedSessions = [];
        }
    }

    public function initializeSession(session_id:String):void {
        if (session_id.indexOf(" ") > -1) {
            throw new Error("Session ID cannot contain spaces");
        }
        if (_extensionContext && !isSessionInitialized(session_id)) {
            _extensionContext.call(BTNativeMethods.initializeSession, session_id);
        }
        else {
            var errMsg : String = _extensionContext == null ? "ANE context creation failed" : "Session already initialized";
            dispatchEvent(new BTErrorEvent(errMsg));
        }
    }

    public function createDownloadTask(session_id:String, remote_url:String, local_path:String):BTDownloadTask {
        var task:BTDownloadTask = new BTDownloadTask(session_id, remote_url, local_path);

        if (_downloadTasks[task.taskID]) {
            dispatchEvent(new BTDebugEvent("Download task with ID " + task.taskID + " already exists"));
            // task with this ID already exists (this download is already running within this session)
            return _downloadTasks[task.taskID];
        }

        if (_extensionContext && isSessionInitialized(session_id)) {
            _extensionContext.call(BTNativeMethods.createDownloadTask, session_id, remote_url, local_path);
            _downloadTasks[task.taskID] = task;
            return task;
        }
        dispatchEvent(new BTErrorEvent("Failed to create download task, is the " + session_id + " session initialized?"));
        return null;
    }

    public function saveFile(local_path:String, fileData:ByteArray):Boolean {

        if (local_path == null || fileData == null) {
            dispatchEvent(new BTErrorEvent("saveFile(): local_path or fileData is null"));
            return false;
        }
        return _extensionContext.call(BTNativeMethods.saveFileTask, local_path, fileData);
    }

    public function unzipFile(zipFilePath:String, destPath:String):void {
        if (zipFilePath == null || destPath == null) {
            dispatchEvent(new BTUnzipErrorEvent("unzipFile(): zipFilePath or destPath is null"));
            return;
        }
        var zipFile : File = new File(zipFilePath);
        if (!zipFile.exists) {
            dispatchEvent(new BTUnzipErrorEvent("Zip file does not exist " + zipFile.nativePath));
        }
        _extensionContext.call(BTNativeMethods.unZipTask, zipFilePath, destPath);
    }

    public function isSessionInitialized(session_id:String):Boolean {
        return _initializedSessions.indexOf(session_id) >= 0;
    }

    // does NOT work on Android/PC!
    internal function resumeDownloadTask(task:BTDownloadTask):void {
        if (_extensionContext && isSessionInitialized(task.sessionID)) {
            _extensionContext.call(BTNativeMethods.resumeDownloadTask, task.taskID);
        }
    }

    // does NOT work on Android/PC!
    internal function suspendDownloadTask(task:BTDownloadTask):void {
        if (_extensionContext && isSessionInitialized(task.sessionID)) {
            _extensionContext.call(BTNativeMethods.suspendDownloadTask, task.taskID);
        }
    }

    internal function cancelDownloadTask(task:BTDownloadTask):void {
        if (_extensionContext && isSessionInitialized(task.sessionID)) {
            _extensionContext.call(BTNativeMethods.cancelDownloadTask, task.taskID);
        }
    }

    private function onSessionInitialized(session_id:String, running_tasks_ids:Array):void {
        _initializedSessions.push(session_id);
        var runningTasks:Array = [];

        for (var i:int = 0; i < running_tasks_ids.length; i++) {
            var taskID:String = unescape(running_tasks_ids[i]);// unescape spaces within id
            var taskProperties:Array = _extensionContext.call(BTNativeMethods.getDownloadTaskPropertiesArray, taskID) as Array;

            if (taskProperties) {
                var task:BTDownloadTask = new BTDownloadTask(taskProperties[0], taskProperties[1], taskProperties[2]);
                if (!_downloadTasks[task.taskID]) {
                    _downloadTasks[task.taskID] = task;
                    runningTasks.push(task);
                }
            }
        }
        dispatchEvent(new BTSessionInitializedEvent(session_id, runningTasks));
    }

    private function onDownloadTaskProgress(task_id:String, bytes_written:Number, total_bytes:Number):void {
        var task:BTDownloadTask = _downloadTasks[task_id];
        if (task) {
            task.dispatchProgress(bytes_written, total_bytes);
        }
        else {
            dispatchEvent(new BTErrorEvent("Received progress event from unknown task " + task_id));
        }
    }

    private function onDownloadTaskCompleted(task_id:String):void {
        var task:BTDownloadTask = _downloadTasks[task_id];
        delete _downloadTasks[task_id];
        if (task) {
            task.dispatchCompleted();
        }
    }

    private function onDownloadTaskError(task_id:String, error:String):void {
        var task:BTDownloadTask = _downloadTasks[task_id];
        delete _downloadTasks[task_id];
        if (task) {
            task.dispatchError(error);
        }
        else {
            dispatchEvent(new BTErrorEvent("Download task error taskId: " + task_id + " message: " + error));
        }
    }

    private function onStatusEvent(event:StatusEvent):void {
        var data:Array;
        var taskID:String;

        switch (event.level) {
            case BTInternalMessages.SESSION_INITIALIZED:
            {
                data = event.code.split(" ");
                var sessionID:String = data.shift();
                onSessionInitialized(sessionID, data);
                break;
            }
            case BTInternalMessages.DOWNLOAD_TASK_PROGRESS:
            {
                data = event.code.split(" ");
                var totalBytes:Number = parseFloat(data.pop());
                var bytesWritten:Number = parseFloat(data.pop());
                taskID = unescape(data.join(" "));
                onDownloadTaskProgress(taskID, bytesWritten, totalBytes);
                break;
            }
            case BTInternalMessages.DOWNLOAD_TASK_COMPLETED:
            {
                taskID = unescape(event.code);
                onDownloadTaskCompleted(taskID);
                break;
            }
            case BTInternalMessages.DOWNLOAD_TASK_ERROR:
            {
                // event.code looks like "taskId urlEncodedStuff anotherUrlEncodedStuff"
                data = event.code.split(" ");
                taskID = unescape(data.shift());
                var error:String = data.join(" ");
                onDownloadTaskError(taskID, error);
                break;
            }
            case BTInternalMessages.UNZIP_PROGRESS:
            {
                dispatchEvent(new BTUnzipProgressEvent(parseInt(event.code)));
                break;
            }
            case BTInternalMessages.UNZIP_COMPLETE:
            {
                dispatchEvent(new BTUnzipCompletedEvent());
                break;
            }
            case BTInternalMessages.UNZIP_ERROR:
            {
                dispatchEvent(new BTUnzipErrorEvent(event.code));
                break;
            }
            case BTInternalMessages.DEBUG_LOG:
            {
                dispatchEvent(new BTDebugEvent(event.code));
                break;
            }
            case BTInternalMessages.ERROR:
            {
                dispatchEvent(new BTErrorEvent(event.code));
                break;
            }
            default:
            {
                dispatchEvent(new BTErrorEvent("Unknown event '" + event.level + "' message:" + event.code));
                break;
            }
        }
    }
}
}