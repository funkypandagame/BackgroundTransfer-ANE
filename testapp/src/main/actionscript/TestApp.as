package
{

    import com.ncreated.ane.backgroundtransfer.BTDebugEvent;
    import com.ncreated.ane.backgroundtransfer.BTDownloadTask;
    import com.ncreated.ane.backgroundtransfer.BTErrorEvent;
    import com.ncreated.ane.backgroundtransfer.BTSessionInitializedEvent;
    import com.ncreated.ane.backgroundtransfer.BackgroundTransfer;

    import feathers.controls.Button;
    import feathers.controls.ScrollContainer;
    import feathers.controls.ScrollText;
    import feathers.layout.TiledColumnsLayout;
    import feathers.themes.MetalWorksMobileTheme;

    import flash.events.ErrorEvent;

    import flash.events.ProgressEvent;
    import flash.filesystem.File;

    import flash.system.Capabilities;

    import flash.text.TextFormat;
    import flash.utils.getTimer;

    import starling.display.Sprite;
    import starling.events.Event;

    public class TestApp extends Sprite
    {

        private static var _instance : TestApp;
        private var service : BackgroundTransfer;

        private var logTF : ScrollText;
        private var buttonBarHeight : uint = 405;
        private const container: ScrollContainer = new ScrollContainer();
        private var currentTask : BTDownloadTask;
        private static const SESSION_ID : String = "SESSION_ID";

        private var lastProgressDisplayed : Number = 0;

        public function TestApp()
        {
            _instance = this;
            addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        }

        protected function addedToStageHandler(event : Event) : void
        {
            removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);

            stage.addEventListener(Event.RESIZE, function(evt : Event) : void
            {
                logTF.height = stage.stageHeight - buttonBarHeight;
                logTF.width = stage.stageWidth;
                container.width = stage.stageWidth;
            });

            new MetalWorksMobileTheme();

            var layout : TiledColumnsLayout = new TiledColumnsLayout();
            layout.useSquareTiles = false;
            layout.gap = 3;
            container.layout = layout;
            container.width = stage.stageWidth;

            addChild(container);

            logTF = new ScrollText();

            logTF.width = stage.stageWidth;

            logTF.textFormat = new TextFormat(null, 22, 0xdedede);
            addChild(logTF);
            var button : Button;

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void {
               service.initializeSession(SESSION_ID);
            });
            button.label = "init session";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void {
                var currentTask : BTDownloadTask = service.createDownloadTask(SESSION_ID, "http://www.google.com/sdfgsdsdf",
                                        File.applicationStorageDirectory.nativePath + "/dsfsdf.zip");
                if (currentTask) {
                    currentTask.addEventListener(ProgressEvent.PROGRESS, logDownloadProgress);
                    currentTask.addEventListener(flash.events.Event.COMPLETE, function(evt:flash.events.Event):void {
                        log("DownloadTaskComplete");
                    });
                    currentTask.addEventListener(ErrorEvent.ERROR, function(evt:ErrorEvent):void {
                        log("DownloadTaskError " + evt.text);
                    });
                }
                else {
                    log("Failed to create download task!")
                }
            });
            button.label = "download wrong URL";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void {
                currentTask = service.createDownloadTask(SESSION_ID, "https://s3.amazonaws.com/rinoa-mountain/artAssets/master-723/full/PC_SD.zip",
                                        File.applicationStorageDirectory.nativePath + "/dsfsdf.zip");
                if (currentTask) {
                    currentTask.addEventListener(ProgressEvent.PROGRESS, logDownloadProgress);
                    currentTask.addEventListener(flash.events.Event.COMPLETE, function(evt:flash.events.Event):void {
                        log("DownloadTaskComplete");
                    });
                    currentTask.addEventListener(ErrorEvent.ERROR, function(evt:ErrorEvent):void {
                        log("DownloadTaskError " + evt.text);
                    });
                }
                else {
                    log("Failed to create download task!")
                }
            });
            button.label = "download good URL";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void {
                if (currentTask) {
                    currentTask.cancel();
                }
                else {
                    log("No current download!")
                }
            });
            button.label = "cancel good URL";
            button.validate();
            container.addChild(button);

            button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void {
                logTF.text = "";
            });
            button.label = "clear";
            button.validate();
            container.addChild(button);

            buttonBarHeight = Math.ceil(0.5 * container.numChildren) * 60 + 5;
            container.height = buttonBarHeight;
            logTF.height = stage.stageHeight - buttonBarHeight;
            logTF.y = buttonBarHeight;

            log("Testing application for the downloader ANE.");

            try {
                service = BackgroundTransfer.instance;
            }
            catch (err : Error) {
                log("Cannot create BackgroundTransfer " + err + "\n" + err.getStackTrace());
                return;
            }

            service.addEventListener(BTSessionInitializedEvent.INITIALIZED, function (evt : BTSessionInitializedEvent) : void {
                log("initialized. Running tasks:" + evt.runningTasks + "; Session ID:" + evt.sessionID);
            });
            service.addEventListener(BTDebugEvent.TYPE, function (evt : BTDebugEvent) : void {
                log("DEBUG " + evt.message);
            });
            service.addEventListener(BTErrorEvent.TYPE, function (evt : BTErrorEvent) : void {
                log("ERROR " + evt.message);
            });
        }

        private function logDownloadProgress(evt : ProgressEvent) : void
        {
            if (getTimer() - lastProgressDisplayed > 1000) {// to prevent message spam
                lastProgressDisplayed = getTimer();
                log("OnProgress " +  (evt.bytesLoaded/1024/1024).toFixed(2) + "/" + (evt.bytesTotal/1024/1024).toFixed(2) + " MB");
            }
        }

        public function log(str : String) : void
        {
            logTF.text += str + "\n";
            trace(str);
        }

        public static function log(str: String) : void
        {
            if (_instance) {
                _instance.log(str);
            }
            else {
                trace(str);
            }
        }

        private static function get isAndroid() : Boolean
        {
            return (Capabilities.manufacturer.indexOf("Android") > -1);
        }

        private static function get isiOS() : Boolean
        {
            return (Capabilities.manufacturer.indexOf("iOS") > -1);
        }
    }
}
