package com.funkypanda.backgroundTransfer.activity;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

public class SampleActivity extends Activity
{

    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);


        finish();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data)
    {
        // this calls onIabPurchaseFinished()
    }



}

