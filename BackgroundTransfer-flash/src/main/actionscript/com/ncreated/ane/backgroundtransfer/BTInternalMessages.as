package com.ncreated.ane.backgroundtransfer {

/**
 * Static consts with names of messages sent by native code.
 */
internal class BTInternalMessages {

    internal static const SESSION_INITIALIZED:String = "session initialized";
    internal static const DOWNLOAD_TASK_PROGRESS:String = "download task progress";
    internal static const DOWNLOAD_TASK_COMPLETED:String = "download task completed";
    internal static const DOWNLOAD_TASK_ERROR:String = "download task error";

    // android only
    internal static const DEBUG_LOG : String = "debug log";
    internal static const ERROR : String = "bt error";

}
}
