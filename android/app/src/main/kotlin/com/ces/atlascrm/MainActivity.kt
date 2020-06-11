package com.ces.atlascrm

//import com.scanlibrary.ScanActivity
//import com.scanlibrary.ScanConstants
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.database.Cursor
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Environment
import android.provider.MediaStore
import androidx.annotation.NonNull
import androidx.core.content.FileProvider
import com.labters.documentscanner.ImageCropActivity
import com.labters.documentscanner.helpers.ScannerConstants
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.*

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.ces.atlascrm.channel"

    private var CROP_REQUEST_CODE = 9584
    private var OPEN_CAMERA_REQUEST_CODE = 5469
    private var OPEN_MEDIA_REQUEST_CODE = 4596

    private var currentPhotoPath: String = ""
    private var CURRENT_RESULT: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        ScannerConstants.backText = "CANCEL"
        ScannerConstants.cropText = "FINISH"
        ScannerConstants.saveStorage = false
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            CURRENT_RESULT = result
            when (call.method.toUpperCase()) {
                "OPENCAMERA" -> {
                    Intent(MediaStore.ACTION_IMAGE_CAPTURE).also { takePictureIntent ->
                        // Ensure that there's a camera activity to handle the intent
                        takePictureIntent.resolveActivity(packageManager)?.also {
                            // Create the File where the photo should go
                            val photoFile: File? = try {
                                // Create an image file name
                                val timeStamp: String = SimpleDateFormat("yyyyMMdd_HHmmss").format(Date())
                                val storageDir: File = getExternalFilesDir(Environment.DIRECTORY_PICTURES)
                                File.createTempFile(
                                        "JPEG_${timeStamp}_", /* prefix */
                                        ".jpg", /* suffix */
                                        storageDir /* directory */
                                ).apply {
                                    // Save a file: path for use with ACTION_VIEW intents
                                    currentPhotoPath = absolutePath
                                }
                            } catch (ex: IOException) {
                                // Error occurred while creating the File
//                                println("aafafaf")
                                null
                            }
                            // Continue only if the File was successfully created
                            photoFile?.also {
                                val photoURI: Uri = FileProvider.getUriForFile(
                                        this,
                                        "com.ces.atlascrm.fileprovider",
                                        it
                                )
                                takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, photoURI)
                                startActivityForResult(takePictureIntent, OPEN_CAMERA_REQUEST_CODE)
                            }
                        }
                    }

//                    Intent(MediaStore.ACTION_IMAGE_CAPTURE).also { takePictureIntent ->
//                        takePictureIntent.resolveActivity(packageManager)?.also {
//                            startActivityForResult(takePictureIntent, OPEN_CAMERA_REQUEST_CODE)
//                        }
//                    }

//                    val preference: Int = ScanConstants.OPEN_CAMERA
//                    val intent = Intent(this@MainActivity, ScanActivity::class.java)
//                    intent.putExtra(ScanConstants.OPEN_INTENT_PREFERENCE, preference)
//                    startActivityForResult(intent, REQUEST_CODE)
                }
                "OPENMEDIA" -> {
                    val intent = Intent()
                    intent.type = "image/*"
                    intent.action = Intent.ACTION_GET_CONTENT
                    startActivityForResult(Intent.createChooser(intent, "Select Picture"), OPEN_MEDIA_REQUEST_CODE)


//                    val getIntent = Intent(Intent.ACTION_GET_CONTENT)
//                    getIntent.type = "image/*"
//                    val pickIntent = Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI)
//                    pickIntent.type = "image/*"
//                    val chooserIntent = Intent.createChooser(getIntent, "Select Image")
//                    chooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, arrayOf(pickIntent))
//                    startActivityForResult(chooserIntent,  OPEN_MEDIA_REQUEST_CODE)


//                    val preference: Int = ScanConstants.OPEN_MEDIA
//                    val intent = Intent(this@MainActivity, ScanActivity::class.java)
//                    intent.putExtra(ScanConstants.OPEN_INTENT_PREFERENCE, preference)
//                    startActivityForResult(intent, OPEN_MEDIA_REQUEST_CODE)
                }
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == OPEN_CAMERA_REQUEST_CODE && resultCode == Activity.RESULT_OK) {
//            val imageBitmap = data?.extras?.get("data") as Bitmap

            val bitmap: Bitmap = BitmapFactory.decodeFile(currentPhotoPath, BitmapFactory.Options())


            ScannerConstants.selectedImageBitmap = bitmap
            startActivityForResult(Intent(MainActivity@ this, ImageCropActivity::class.java), CROP_REQUEST_CODE)
        }

        if (requestCode == OPEN_MEDIA_REQUEST_CODE && resultCode == Activity.RESULT_OK) {
//            val imageBitmap = data?.extras?.get("data") as Bitmap
            val uri = data?.data

            val bitmap = MediaStore.Images.Media.getBitmap(contentResolver, uri)

            ScannerConstants.selectedImageBitmap = bitmap
            startActivityForResult(Intent(MainActivity@ this, ImageCropActivity::class.java), CROP_REQUEST_CODE)
        }


        if (requestCode == CROP_REQUEST_CODE && resultCode == Activity.RESULT_OK) {

            try {

                val bytes = ByteArrayOutputStream()
                ScannerConstants.selectedImageBitmap.compress(Bitmap.CompressFormat.JPEG, 100, bytes)
                val newImgPath = MediaStore.Images.Media.insertImage(context.contentResolver, ScannerConstants.selectedImageBitmap, UUID.randomUUID().toString(), null)

                val realPath = getRealPathFromURI(context, Uri.parse(newImgPath))


                CURRENT_RESULT?.success(realPath)
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
