/**
 *  Copyright (c)  2009 coltware@gmail.com
 *  http://www.coltware.com
 *
 *  License: LGPL v3 ( http://www.gnu.org/licenses/lgpl-3.0-standalone.html )
 *
 * @author coltware@gmail.com
 */
package com.coltware.airxzipANE.crypt
{
import com.coltware.airxzipANE.ZipEntry;
import com.coltware.airxzipANE.ZipHeader;

import flash.utils.ByteArray;

public interface ICrypto
{

    function checkDecrypt(entry : ZipEntry) : Boolean;

    /**
     *   initialize decrypto
     */
    function initDecrypt(password : ByteArray, header : ZipHeader) : void;

    /**
     *   decrypto
     */
    function decrypt(data : ByteArray) : ByteArray;

    /**
     *   initialize encrypto
     */
    function initEncrypt(password : ByteArray, header : ZipHeader) : void;

    /**
     *  encrypto
     */
    function encrypt(data : ByteArray) : ByteArray;
}
}