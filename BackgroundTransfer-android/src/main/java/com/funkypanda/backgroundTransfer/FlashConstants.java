package com.funkypanda.backgroundTransfer;


public class FlashConstants {

    ////////////////////////////////////////////////////////////////////// event codes
    final public static String SESSION_INITIALIZED = "session initialized";
    final public static String DOWNLOAD_TASK_PROGRESS = "download task progress";
    final public static String DOWNLOAD_TASK_COMPLETED = "download task completed";
    final public static String DOWNLOAD_TASK_ERROR = "download task error";
    final public static String DEBUG_LOG = "debug log";
    final public static String ERROR = "bt error";

    final public static String UNZIP_COMPLETE = "unzip complete";
    final public static String UNZIP_PROGRESS = "unzip progress";
    final public static String UNZIP_ERROR = "unzip error";

    // function names
    final public static String initializeSession = "BGT_initializeSession";
    final public static String createDownloadTask = "BGT_createDownloadTask";
    final public static String getDownloadTaskPropertiesArray = "BGT_getDownloadTaskPropertiesArray";
    final public static String resumeDownloadTask = "BGT_resumeDownloadTask";
    final public static String suspendDownloadTask = "BGT_suspendDownloadTask";
    final public static String cancelDownloadTask = "BGT_cancelDownloadTask";

    final public static String saveFileTask = "BGT_saveFileTask";
    final public static String unZipTask = "BGT_extractZipTask";

}
