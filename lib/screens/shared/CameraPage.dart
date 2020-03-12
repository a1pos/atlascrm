import 'dart:io';

import 'package:atlascrm/components/CenteredClearLoadingScreen.dart';
import 'package:atlascrm/components/CustomAppBar.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Function callback;

  CameraPage({this.cameras, this.callback});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  static const platform = const MethodChannel('com.ces.atlascrm.channel');

  bool isLoading = true;

  Image currentPreviewImage;

  String tempImageFilePath;
  String finalImageFilePath;

  CameraController cameraController;

  Image preview;

  bool isPreviewReady = false;

  @override
  void initState() {
    super.initState();

    isPreviewReady = false;

    cameraController =
        CameraController(this.widget.cameras[0], ResolutionPreset.ultraHigh);

    initializeCameraController();
  }

  @override
  Future<void> dispose() async {
    super.dispose();

    await cameraController?.dispose();
  }

  Future<void> initializeCameraController() async {
    var appDirectory = await getApplicationDocumentsDirectory();

    tempImageFilePath = "${appDirectory.path}/scannerTempImages";
    finalImageFilePath = "${appDirectory.path}/scannerFinalImages";

    var tempDir = new Directory(tempImageFilePath);
    var finalDir = new Directory(finalImageFilePath);

    if (!await tempDir.exists()) {
      await tempDir.create();
    } else {
      for (var f in await tempDir.list().toList()) {
        await f.delete();
      }
    }

    if (!await finalDir.exists()) {
      await finalDir.create();
    } else {
      for (var f in await finalDir.list().toList()) {
        await f.delete();
      }
    }

    await cameraController.initialize();

    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveImage() async {
    try {
      var tempImageFile =
          File(tempImageFilePath + "/temp_${DateTime.now()}.jpeg");
      var finalImageFile =
          File(finalImageFilePath + "/processed_${DateTime.now()}.jpeg");

      if (await tempImageFile.exists()) {
        await tempImageFile.delete();
      }

      if (await finalImageFile.exists()) {
        await finalImageFile.delete();
      }

      await cameraController.takePicture(tempImageFile.path);

      await platform.invokeMethod(
          'PROCESS_IMAGE', [tempImageFile.path, finalImageFile.path]);

      setState(() {
        isPreviewReady = true;
        preview = Image.file(File(finalImageFile.path));
      });
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!cameraController.value.isInitialized && isLoading) {
      return CenteredClearLoadingScreen();
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: Text("asdf"),
      ),
      body: Container(
        child: isPreviewReady
            ? Container(
                child: Image(
                  image: preview.image,
                ),
              )
            : Stack(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: cameraController.value.aspectRatio,
                          child: CameraPreview(cameraController),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(15, 100, 15, 100),
                    height: MediaQuery.of(context).size.height - 15,
                    width: MediaQuery.of(context).size.width - 15,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.red,
                        width: 5.0,
                      ),
                      color: Colors.transparent,
                    ),
                  )
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await saveImage();
        },
        child: Icon(Icons.camera),
      ),
    );
  }
}
