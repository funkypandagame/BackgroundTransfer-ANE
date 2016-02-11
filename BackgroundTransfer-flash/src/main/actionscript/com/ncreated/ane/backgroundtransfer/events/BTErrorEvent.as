package com.ncreated.ane.backgroundtransfer.events
{
import flash.events.Event;

public class BTErrorEvent extends Event
{

    public static const TYPE : String = "BTErrorEvent";

    private var _message:String;

    public function BTErrorEvent(message : String)
    {
        super(TYPE);
        _message = message;
    }

    public function get message():String {
        return _message;
    }

    override public function clone() : Event {
        return new BTErrorEvent(_message);
    }
}
}
