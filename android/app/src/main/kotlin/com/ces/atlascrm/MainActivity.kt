package com.ces.atlascrm

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.database.Cursor
import android.graphics.Bitmap
import android.net.Uri
import android.os.Environment
import android.provider.MediaStore
import androidx.annotation.NonNull
import com.scanlibrary.ScanActivity
import com.scanlibrary.ScanConstants
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.FileOutputStream
import java.io.IOException
import java.util.*

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.ces.atlascrm.channel"
    private var REQUEST_CODE = 958
    private var CURRENT_RESULT: MethodChannel.Result? = null
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            CURRENT_RESULT = result
            when (call.method.toUpperCase()) {
                "OPENCAMERA" -> {
                    val preference: Int = ScanConstants.OPEN_CAMERA
                    val intent = Intent(this@MainActivity, ScanActivity::class.java)
                    intent.putExtra(ScanConstants.OPEN_INTENT_PREFERENCE, preference)
                    startActivityForResult(intent, REQUEST_CODE)
                }
                "OPENMEDIA" -> {
                    val preference: Int = ScanConstants.OPEN_MEDIA
                    val intent = Intent(this@MainActivity, ScanActivity::class.java)
                    intent.putExtra(ScanConstants.OPEN_INTENT_PREFERENCE, preference)
                    startActivityForResult(intent, REQUEST_CODE)
                }
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE && resultCode == Activity.RESULT_OK) {
            try {
                val uri =
                        data?.extras!!.getParcelable<Uri>(ScanConstants.SCANNED_RESULT)
//                val bitmap = MediaStore.Images.Media.getBitmap(contentResolver, uri);
                val path = getRealPathFromURI(context, uri)
//
//                val path = "${Environment.getExternalStorageDirectory()}/${UUID.randomUUID()}.png"
//
//                FileOutputStream("$path").use { out ->
//                    bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
//                }

                CURRENT_RESULT?.success(path)
            } catch (e: IOException) {
                e.printStackTrace()
            }
        }
    }
    fun getRealPathFromURI(context: Context, contentUri: Uri?): String? {
        var cursor: Cursor? = null
        return try {
            val proj = arrayOf(MediaStore.Images.Media.DATA)
            cursor = context.contentResolver.query(contentUri, proj, null, null, null)
            val columnIndex: Int = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA)
            cursor.moveToFirst()
            cursor.getString(columnIndex)
        } finally {
            cursor?.close()
        }
    }
}
