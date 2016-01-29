package {

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.UncaughtErrorEvent;
import flash.geom.Rectangle;

import starling.core.Starling;
import starling.utils.HAlign;
import starling.utils.VAlign;

public class Main extends Sprite {

    private var _starling:Starling;

    public function Main()
    {
        loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,
            function (event : UncaughtErrorEvent):void
            {
                var errStr : String;
                var errId : int = 0;
                if (event.error is Error)
                {
                    var stackTrace : String = event.error.getStackTrace();
                    errId = event.error.errorID;
                    errStr = event.error.toString() + "\n" + stackTrace;
                }
                else if (event.error is ErrorEvent)
                {
                    var errorEvent : ErrorEvent = event.error;
                    errId = errorEvent.errorID;
                    errStr = errorEvent.text;
                }
                else
                {
                    errStr = event.error.toString();
                }
                TestApp.log("UNCAUGHT ERROR " + errStr);
            });
        mouseEnabled = mouseChildren = false;
        loaderInfo.addEventListener(Event.COMPLETE, loaderInfo_completeHandler);
    }

    private function loaderInfo_completeHandler(event:Event):void
    {
        stage.align = StageAlign.TOP_LEFT;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.frameRate = 60;
        Starling.handleLostContext = true;
        Starling.multitouchEnabled = true;
        _starling = new Starling(TestApp, this.stage);
        _starling.enableErrorChecking = false;
        _starling.start();
        _starling.showStatsAt(HAlign.RIGHT, VAlign.BOTTOM);

        stage.addEventListener(Event.RESIZE, stage_resizeHandler, false, int.MAX_VALUE, true);
        stage.addEventListener(Event.DEACTIVATE, stage_deactivateHandler, false, 0, true);
    }

    private function stage_resizeHandler(event:Event):void
    {
        this._starling.stage.stageWidth = stage.stageWidth;
        this._starling.stage.stageHeight = stage.stageHeight;

        const viewPort:Rectangle = _starling.viewPort;
        viewPort.width = stage.stageWidth;
        viewPort.height = stage.stageHeight;
        try
        {
            this._starling.viewPort = viewPort;
        }
        catch(error:Error) {}
    }

    private function stage_deactivateHandler(event:Event):void
    {
        _starling.stop();
        stage.addEventListener(Event.ACTIVATE, stage_activateHandler, false, 0, true);
    }

    private function stage_activateHandler(event:Event):void
    {
        stage.removeEventListener(Event.ACTIVATE, stage_activateHandler);
        _starling.start();
    }



}
}
