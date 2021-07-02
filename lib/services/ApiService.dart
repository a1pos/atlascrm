import 'dart:async';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:round2crm/config/ConfigSettings.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'UserService.dart';

class ApiService {
  final String URLBASE = ConfigSettings.HOOK_API_URL;
  final int TIMEOUT = 10000;

  var logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    // output:
  );

  Future<Response> publicGet(url, data) async {
    logger.i("Connecting to: " + URLBASE.toString());
    try {
      return await Dio(
        BaseOptions(
          baseUrl: URLBASE,
          responseType: ResponseType.json,
          headers: {
            "Content-Type": "application/json",
          },
          sendTimeout: TIMEOUT,
        ),
      ).get(url);
    } catch (err) {
      logger.e(err.toString());
      throw err;
    }
  }

  Future<Response> publicPost(url, data) async {
    try {
      logger.i("Connecting to: " + URLBASE.toString());

      return await Dio(
        BaseOptions(
          baseUrl: URLBASE,
          responseType: ResponseType.json,
          headers: {
            "Content-Type": "application/json",
          },
          sendTimeout: TIMEOUT,
        ),
      ).post(
        url,
        data: jsonEncode(data),
      );
    } catch (err) {
      logger.e(err.toString());
      throw err;
    }
  }

  Future<Response> authGet(context, url, {isRetry: false}) async {
    try {
      logger.i("Connecting to: " + URLBASE.toString());

      var token = UserService.token;

      var resp = await Dio(
        BaseOptions(
          baseUrl: URLBASE,
          responseType: ResponseType.json,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          sendTimeout: TIMEOUT,
          validateStatus: (status) {
            return status < 500;
          },
        ),
      ).get(url);

      if (resp.statusCode == 401) {
        logger.e("401 error code, logging out");
        Navigator.of(context).popAndPushNamed('/logout');
        return null;
      }
      return resp;
    } catch (err) {
      logger.e(err.toString());
      if (checkAuthErrorResponse(context, err)) {
        Navigator.of(context).popAndPushNamed('/logout');
        return null;
      } else {
        throw err;
      }
    }
  }

  Future<Response> authPost(context, url, data,
      {isFile = false, isRetry: false}) async {
    try {
      logger.i("Connecting to: " + URLBASE.toString());

      var token = UserService.token;

      var resp = await Dio(
        BaseOptions(
          baseUrl: URLBASE,
          responseType: ResponseType.json,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          sendTimeout: TIMEOUT,
        ),
      ).post(
        url,
        data: jsonEncode(data),
      );

      if (resp.statusCode == 401) {
        logger.e("401 error code, logging out");
        Navigator.of(context).popAndPushNamed('/logout');
        return null;
      }
      return resp;
    } catch (err) {
      logger.e(err.toString());
      if (checkAuthErrorResponse(context, err)) {
        Navigator.of(context).popAndPushNamed('/logout');
        return null;
      } else {
        throw err;
      }
    }
  }

  Future<Response> authFilePost(context, url, filePath, {isRetry: true}) async {
    try {
      logger.i("Connecting to: " + URLBASE.toString());

      logger.i("Context: " +
          context.toString() +
          ", \nUrl: " +
          url.toString() +
          ", \nfilePath: " +
          filePath.toString());
      var token = UserService.token;

      var type = "application";
      var subType = "octet-stream";
      if (filePath.contains(".jpg") ||
          filePath.contains(".jpeg") ||
          filePath.contains(".JPG") ||
          filePath.contains(".JPEG")) {
        type = "image";
        subType = "jpeg";
      }
      if (filePath.contains(".png") || filePath.contains(".PNG")) {
        type = "image";
        subType = "png";
      }
      if (filePath.contains(".pdf") || filePath.contains(".PDF")) {
        type = "application";
        subType = "pdf";
      }

      var f = MultipartFile.fromFileSync(filePath,
          contentType: MediaType(type, subType));
      var formData = FormData.fromMap({"statement": f});

      var resp = await Dio(
        BaseOptions(
          baseUrl: URLBASE,
          headers: {
            "Content-Type": "multipart/form-data",
            "Authorization": "Bearer $token",
          },
          sendTimeout: 10000,
        ),
      ).post(url, data: formData);

      if (resp.statusCode == 401) {
        logger.e("401 error code, logging out");
        Navigator.of(context).popAndPushNamed('/logout');
        return null;
      }
      return resp;
    } catch (err) {
      logger.e("Error posting file: " + err.toString());
      throw "Error posting file: " + err.toString();
    }
  }

  Future<Response> authFilePostWithFormData(context, url, FormData formData,
      {isRetry: true}) async {
    Map message = {
      "context": context,
      "url": url,
      "formData": formData,
    };
    logger.i(message.toString());
    try {
      logger.i("Connecting to: " + URLBASE.toString());

      var token = UserService.token;

      var resp = await Dio(
        BaseOptions(
          baseUrl: URLBASE,
          headers: {
            "Content-Type": "multipart/form-data",
            "Authorization": "Bearer $token",
          },
          sendTimeout: 10000,
        ),
      ).post(url, data: formData);

      if (resp.statusCode == 401) {
        logger.e("401 error code, logging out");
        Navigator.of(context).popAndPushNamed('/logout');
        return null;
      }
      return resp;
    } catch (err) {
      logger.e("Error posting files with form data: " + err.toString());
      throw "Error posting files with form data: " + err.toString();
    }
  }

  Future<Response> authFilesPost(context, url, filePaths,
      {isRetry: true, fileName: "file"}) async {
    try {
      logger.i("Connecting to: " + URLBASE.toString());

      var token = UserService.token;

      var formData = FormData();

      for (var fPath in filePaths) {
        var type = "application";
        var subType = "octet-stream";
        if (fPath.contains(".jpg") ||
            fPath.contains(".jpeg") ||
            fPath.contains(".JPG") ||
            fPath.contains(".JPEG")) {
          type = "image";
          subType = "jpeg";
        }
        if (fPath.contains(".png") || fPath.contains(".PNG")) {
          type = "image";
          subType = "png";
        }
        if (fPath.contains(".pdf") || fPath.contains(".PDF")) {
          type = "application";
          subType = "pdf";
        }
        if (fPath != "") {
          var file = MultipartFile.fromFileSync(fPath,
              contentType: MediaType(type, subType));
          formData.files.add(MapEntry(fileName, file));
        } else {
          formData.files.add(MapEntry(fileName, null));
        }
      }

      var resp = await Dio(
        BaseOptions(
          baseUrl: URLBASE,
          headers: {
            "Content-Type": "multipart/form-data",
            "Authorization": "Bearer $token",
          },
          sendTimeout: TIMEOUT,
        ),
      ).post(url, data: formData);

      if (resp.statusCode == 401) {
        logger.e("401 error code, logging out");
        Navigator.of(context).popAndPushNamed('/logout');
        return null;
      }
      return resp;
    } catch (err) {
      logger.e("Error posting files: " + err.toString());
      if (checkAuthErrorResponse(context, err)) {
        Navigator.of(context).popAndPushNamed('/logout');
        return null;
      } else {
        throw "Error posting files: " + err.toString();
      }
    }
  }

  Future<Response> authPut(context, url, data, {isRetry: false}) async {
    try {
      logger.i("Connecting to: " + URLBASE.toString());

      var token = UserService.token;

      var resp = await Dio(
        BaseOptions(
          baseUrl: URLBASE,
          responseType: ResponseType.json,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          sendTimeout: TIMEOUT,
        ),
      ).put(url, data: jsonEncode(data));

      if (resp.statusCode == 401) {
        logger.e("401 error code, logging out");
        Navigator.of(context).popAndPushNamed('/logout');
        return null;
      }
      return resp;
    } catch (err) {
      logger.e(err.toString());
      if (checkAuthErrorResponse(context, err)) {
        Navigator.of(context).popAndPushNamed('/logout');
        return null;
      } else {
        throw err;
      }
    }
  }

  Future<Response> authDelete(context, url, data, {isRetry: false}) async {
    try {
      logger.i("Connecting to: " + URLBASE.toString());

      var token = UserService.token;

      var resp = await Dio(
        BaseOptions(
          baseUrl: URLBASE,
          responseType: ResponseType.json,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          sendTimeout: TIMEOUT,
        ),
      ).delete(url);

      if (resp.statusCode == 401) {
        logger.e("401 error code, logging out");
        Navigator.of(context).popAndPushNamed('/logout');
        return null;
      }
      return resp;
    } catch (err) {
      logger.e(err.toString());
      if (checkAuthErrorResponse(context, err)) {
        Navigator.of(context).popAndPushNamed('/logout');
        return null;
      } else {
        throw err;
      }
    }
  }

  bool checkAuthErrorResponse(context, msg) {
    try {
      logger.i("Connecting to: " + URLBASE.toString());

      if (msg != null) {
        if (msg.response != null) {
          if (msg.response.statusCode == 401) {
            logger.e("401 error code");
            return true;
          }
        }
      }
    } catch (err) {
      logger.e(err.toString());
    }
    return false;
  }
}
