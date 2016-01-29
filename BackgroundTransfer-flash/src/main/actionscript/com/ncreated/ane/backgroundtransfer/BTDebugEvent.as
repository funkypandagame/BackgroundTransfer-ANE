package com.ncreated.ane.backgroundtransfer
{
import flash.events.Event;

public class BTDebugEvent extends Event
{

    public static const TYPE : String = "BTDebugEvent";

    private var _message:String;

    public function BTDebugEvent(message : String)
    {
        super(TYPE);
        _message = message;
    }

    public function get message():String {
        return _message;
    }
}
}
