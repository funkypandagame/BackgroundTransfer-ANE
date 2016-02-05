package com.funkypanda.backgroundTransfer;

import com.adobe.fre.*;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;

public class ANEUtils {

    public static String getStringFromFREObject(FREObject object)
    {
        try
        {
            return object.getAsString();
        }
        catch (Exception e)
        {
            e.printStackTrace();
            return null;
        }
    }

    public static Boolean getBooleanFromFREObject(FREObject object)
    {
        try
        {
            return object.getAsBool();
        }
        catch(Exception e)
        {
            e.printStackTrace();
            return false;
        }
    }

    public static List<String> getListOfStringFromFREArray(FREArray array)
    {
        List<String> result = new ArrayList<String>();

        try
        {
            for (int i = 0; i < array.getLength(); i++)
            {
                try
                {
                    result.add(getStringFromFREObject(array.getObjectAt((long)i)));
                }
                catch (Exception e)
                {
                    e.printStackTrace();
                }
            }
        }
        catch (Exception e)
        {
            e.printStackTrace();
            return null;
        }

        return result;
    }

    public static FREArray stringArrayToFREArray(String[] toConvert)
    {
        FREArray asVector = null;
        try {
            asVector = FREArray.newArray("String", toConvert.length, false);
            for (int i = 0; i < toConvert.length; i++) {
                FREObject stringElement = FREObject.newObject(toConvert[i]);
                asVector.setObjectAt(i, stringElement);
            }
        } catch (FREASErrorException e) {
            e.printStackTrace();
        } catch (FRENoSuchNameException e) {
            e.printStackTrace();
        } catch (FREWrongThreadException e) {
            e.printStackTrace();
        } catch (FREInvalidObjectException e) {
            e.printStackTrace();
        } catch (FRETypeMismatchException e) {
            e.printStackTrace();
        }
        return asVector;
    }

    public static FREObject booleanAsFREObject(boolean val)
    {
        FREObject toReturn = null;
        try {
            toReturn = FREObject.newObject(val);
        } catch (FREWrongThreadException e) {
            e.printStackTrace();
        }
        return toReturn;
    }

    public static String encodeString(String toEncode)
    {
        String toReturn = "";
        try {
            toReturn = URLEncoder.encode(toEncode, "utf-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return toReturn;
    }
}
