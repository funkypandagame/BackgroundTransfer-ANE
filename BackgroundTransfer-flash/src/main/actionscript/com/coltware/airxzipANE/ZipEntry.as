/**
 *  Copyright (c)  2009 coltware@gmail.com
 *  http://www.coltware.com
 *
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 */
package com.coltware.airxzipANE
{

import flash.events.*;
import flash.utils.*;

use namespace zip_internal;

/**
 *  Zip
 */
public class ZipEntry extends EventDispatcher
{

    public static var METHOD_NONE : int = 0;
    public static var METHOD_DEFLATE : int = 8;

    zip_internal var _header : ZipHeader;
    zip_internal var _headerLocal : ZipHeader;
    private var _content : ByteArray;

    private var _stream : IDataInput;

    public function ZipEntry(stream : IDataInput)
    {
        _stream = stream;
    }

    /**
     *  @private
     */
    public function setHeader(h : ZipHeader) : void
    {
        _header = h;
    }

    public function getHeader() : ZipHeader
    {
        return _header;
    }

    public function getCompressMethod() : int
    {
        return _header.getCompressMethod();
    }

    public function isCompressed() : Boolean
    {
        var method : int = _header.getCompressMethod();
        if (method == 0)
        {
            return false;
        }
        else
        {
            return true;
        }
    }

    public function getFilename(charset : String = null) : String
    {
        return _header.getFilename(charset);
    }

    public function isDirectory() : Boolean
    {
        return _header.isDirectory();
    }

    public function getCompressRate() : Number
    {
        return _header.getCompressRate();
    }

    public function getUncompressSize() : int
    {
        return _header.getUncompressSize();
    }

    public function getCompressSize() : int
    {
        return _header.getCompressSize();
    }

    public function getDate() : Date
    {
        return _header.getDate();
    }

    public function getVersion() : int
    {
        return _header._version;
    }

    public function getHostVersion() : int
    {
        return _header.getVersion();
    }

    public function getCrc32() : String
    {
        return _header._crc32.toString(16);
    }

    public function isEncrypted() : Boolean
    {
        if (_header._bitFlag & 1)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    public function getLocalHeaderOffset() : int
    {
        return _header.getLocalHeaderOffset();
    }

    /**
     * @private
     */
    public function getLocalHeaderSize() : int
    {
        return _header.getLocalHeaderSize();
    }


    zip_internal function dumpLogInfo() : void
    {
        _header.dumpLogInfo();
    }

}
}