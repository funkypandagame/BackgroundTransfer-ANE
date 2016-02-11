package com.ncreated.ane.backgroundtransfer.events {
import flash.events.Event;

public class BTUnzipErrorEvent extends Event{

    public static const TYPE : String = "BTUnzipErrorEvent";
    private var _message:String;

    public function BTUnzipErrorEvent(message : String) {
        super(TYPE);
        _message = message;
    }

    public function get message():String {
        return _message;
    }

    override public function clone() : Event {
        return new BTUnzipErrorEvent(_message);
    }

}
}
