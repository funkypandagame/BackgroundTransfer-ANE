package com.ncreated.ane.backgroundtransfer.events {
import flash.events.Event;

public class BTUnzipProgressEvent extends Event{

    public static const TYPE : String = "BTUnzipProgressEvent";
    private var _progress:int;

    public function BTUnzipProgressEvent(message : int) {
        super(TYPE);
        _progress = message;
    }

    public function get progress():int {
        return _progress;
    }

    override public function clone() : Event {
        return new BTUnzipProgressEvent(_progress);
    }

}
}
