#Background Transfer - Adobe AIR Native Extension for iOS + Android

This [AIR Native Extension](http://www.adobe.com/devnet/air/native-extensions-for-air.html) provides AS3 API to use [iOS Background Transfer Service](http://www.appcoda.com/background-transfer-service-ios7/) and an Android download manager for downloading files in Adobe AIR application.

Starting from iOS7, with Background Transfer Service:

 - downloads and uploads are managed by iOS;                                                                          
 - the transfer continues even when the user sends the app to the background (e.g. switches to another app);
 - there's no time limit for download/upload;
 - if the app crashes during the download/upload, the retransmission will start automatically when the app is launched;

Read more about NSURLSession in Apple documentation: [https://developer.apple.com/library/IOs/documentation/Foundation/Reference/NSURLSession_class/index.html]()
Read more about multitasking in iOS: [NSURLSession and Background Transfer Service](http://www.objc.io/issue-5/multitasking.html)

On Android it uses a multi-threaded download library, [ThinDownloadManager](https://github.com/smanikandan14/ThinDownloadManager)


## Usage

Initialize `BackgroundTransfer` object:

```javascript   
BackgroundTransfer.instance.initializeSession(SESSION_ID);

downloadTask = BackgroundTransfer.instance.createDownloadTask(sessionID, remoteURL, localPath);
downloadTask.addEventListener(ProgressEvent.PROGRESS, onDownloadTaskProgress, false, 0, true);
downloadTask.addEventListener(Event.COMPLETE, onDownloadTaskCompleted, false, 0, true);
downloadTask.addEventListener(ErrorEvent.ERROR, onDownloadTaskError, false, 0, true);
downloadTask.resume();

```

To continue download tasks that were interrupted (for instance, due to app crash) implement initialization event:

```javascript
BackgroundTransfer.instance.addEventListener(BTSessionInitializedEvent.INITIALIZED, onBackgroundSessionInitialized, false, 0, true);

private function onBackgroundSessionInitialized(event:BTSessionInitializedEvent):void {
    for each (var runningTask:BTDownloadTask in event.runningTasks) {
        // continue tasks
    }
}
```

Run the demo project for more implementation details.

## Building

Install Maven. Then run

mvn clean install

To develop with the test app:
1. run mvn clean install to compile the .ANE
2. in IntelliJ's left pane right click on InAppPurchase.ane and select synchronize.
3. run or debug it.

Check ANETest-app.xml that it uses the same name as the app certificate has.

Note: Android has no session handling, so onBackgroundSessionInitialized will always return nothing. Also you downloads will fail it the connectivity changes.


##License

Default (not native) implementation of this ANE uses GreenSock LoaderMax for downloading files. `greensock.swc` library is subject to its own license. Please follow [https://greensock.com/licensing/]() for more details.


------------------------------------

The MIT License (MIT)

Copyright (c) 2014 Maciek Grzybowski & project contributors.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

