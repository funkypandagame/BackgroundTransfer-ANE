package com.ncreated.ane.backgroundtransfer.events {
import flash.events.Event;

public class BTUnzipCompletedEvent extends Event{

    public static const TYPE : String = "BTUnzipCompletedEvent";

    public function BTUnzipCompletedEvent() {
        super(TYPE);
    }

    override public function clone() : Event {
        return new BTUnzipCompletedEvent();
    }
}
}
