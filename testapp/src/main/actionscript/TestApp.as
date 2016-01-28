package
{

import com.ncreated.ane.backgroundtransfer.BTDownloadTask;
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

    import starling.core.Starling;

    import starling.display.Sprite;
    import starling.events.Event;

    public class TestApp extends Sprite
    {

        private var service : BackgroundTransfer;

        private var logTF : ScrollText;
        private static const TOP : uint = 405;
        private const container: ScrollContainer = new ScrollContainer();
        private var currentTask : BTDownloadTask;

        public function TestApp()
        {
            addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        }

        protected function addedToStageHandler(event : Event) : void
        {
            removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);

            stage.addEventListener(Event.RESIZE, function(evt : Event) : void
            {
                logTF.height = stage.stageHeight - TOP;
                logTF.width = stage.stageWidth;
                container.width = stage.stageWidth;
            });


            Starling.current.nativeStage.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,
            function (e:UncaughtErrorEvent):void
            {
                log("UNCAUGHT ERROR " + e.toString());
            });

            new MetalWorksMobileTheme();

            var layout : TiledColumnsLayout = new TiledColumnsLayout();
            layout.useSquareTiles = false;
            container.layout = layout;
            container.width = stage.stageWidth;
            container.height = TOP;
            addChild(container);

            var button : Button = new Button();
            button.addEventListener(Event.TRIGGERED, function (evt : Event) : void
            {
                currentTask = service.createDownloadTask("test_session_id", "www.vaadg34qgf.sdf", ".");
                currentTask.addEventListener(ProgressEvent.PROGRESS, function(evt:ProgressEvent):void {
                });
                if (currentTask) {
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


            logTF = new ScrollText();
            logTF.height = stage.stageHeight - TOP;
            logTF.width = stage.stageWidth;
            logTF.y = TOP;
            logTF.textFormat = new TextFormat(null, 22, 0xdedede);
            addChild(logTF);

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
            service.addEventListener(ErrorEvent.ERROR, function (evt : ErrorEvent) : void
            {
                log("ERROR " + evt.text + " " + evt.errorID);
            });
        }

        private function log(str : String) : void
        {
            logTF.text += str + "\n";
            trace(str);
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
