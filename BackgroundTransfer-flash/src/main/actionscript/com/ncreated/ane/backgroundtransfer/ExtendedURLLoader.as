package com.ncreated.ane.backgroundtransfer {
import flash.net.URLLoader;
import flash.net.URLRequest;

internal class ExtendedURLLoader extends URLLoader
{

    public var localPath : String;
    public var id : String;

    public function ExtendedURLLoader(request:URLRequest = null) {
        super(request);
    }
}
}
