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

import flash.events.UncaughtErrorEvent;
    import flash.system.Capabilities;

    import flash.text.TextFormat;


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
                currentTask = service.createDownloadTask(SESSION_ID, "www.vaadg34qgf.sdf", ".");
                if (currentTask) {
                    currentTask.addEventListener(ProgressEvent.PROGRESS, function(evt:ProgressEvent):void {
                    });
                    currentTask.addEventListener(flash.events.Event.COMPLETE, function(evt:flash.events.Event):void {
                        log("Download task complete");
                    });
                    currentTask.addEventListener(ErrorEvent.ERROR, function(evt:ErrorEvent):void {
                        log("Download task error " + evt.text + " " + evt.errorID);
                    });
                }
                else {
                    log("Failed to create download task!")
                }
            });
            button.label = "create download task";
            button.validate();
            container.addChild(button);

            buttonBarHeight = Math.ceil(0.5 * container.numChildren) * 55 + 5;
            container.height = buttonBarHeight;
            logTF.height = stage.stageHeight - buttonBarHeight;
            logTF.y = buttonBarHeight;

            log("Testing application for the downloader ANE.");

            try {
                service = BackgroundTransfer.instance;
            }
            catch (err : Error)
            {
                log("Cannot create BackgroundTransfer " + err + "\n" + err.getStackTrace());
                return;
            }

            service.addEventListener(BTSessionInitializedEvent.INITIALIZED, function (evt : BTSessionInitializedEvent) : void
            {
                log("initialized " + evt.type + " " + evt.runningTasks + " " + evt.sessionID);
            });
            service.addEventListener(BTDebugEvent.TYPE, function (evt : BTDebugEvent) : void
            {
                log("DEBUG " + evt.message);
            });
            service.addEventListener(BTErrorEvent.TYPE, function (evt : BTErrorEvent) : void
            {
                log("ERROR " + evt.message);
            });
        }

        public function log(str : String) : void
        {
            logTF.text += str + "\n";
            trace(str);
        }

        public static function log(str: String) : void
        {
            if (_instance)
            {
                _instance.log(str);
            }
            else
            {
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
