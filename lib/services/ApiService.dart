import 'dart:async';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:atlascrm/config/ConfigSettings.dart';

import 'package:atlascrm/services/StorageService.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'UserService.dart';

class ApiService {
  final StorageService storageService = new StorageService();
  final String URLBASE = ConfigSettings.HOOK_API_URL;
  final int TIMEOUT = 10000;

  Future<Response> publicGet(url, data) async {
    try {
      return await Dio(
        BaseOptions(
          baseUrl: ConfigSettings.HOOK_API_URL,
          responseType: ResponseType.json,
          headers: {
            "Content-Type": "application/json",
          },
          sendTimeout: TIMEOUT,
        ),
      ).get(url);
    } catch (err) {
      throw err;
    }
  }

  Future<Response> publicPost(url, data) async {
    try {
      return await Dio(
        BaseOptions(
          baseUrl: ConfigSettings.HOOK_API_URL,
          responseType: ResponseType.json,
          headers: {
            "Content-Type": "application/json",
          },
          sendTimeout: TIMEOUT,
        ),
      ).post(url, data: jsonEncode(data));
    } catch (err) {
      throw err;
    }
  }

  Future<Response> authGet(context, url, {isRetry: false}) async {
    try {
      var token = UserService.token;

      var resp = await Dio(
        BaseOptions(
          baseUrl: ConfigSettings.HOOK_API_URL,
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
        Navigator.of(context).popAndPushNamed('/logout');
        return null;
      }
      return resp;
    } catch (err) {
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
      ).post(url, data: jsonEncode(data));

      if (resp.statusCode == 401) {
        Navigator.of(context).popAndPushNamed('/logout');
        return null;
      }
      return resp;
    } catch (err) {
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
        Navigator.of(context).popAndPushNamed('/logout');
        return null;
      }
      return resp;
    } catch (err) {
      throw err;
    }
  }

  Future<Response> authFilePostWithFormData(context, url, FormData formData,
      {isRetry: true}) async {
    try {
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
        Navigator.of(context).popAndPushNamed('/logout');
        return null;
      }
      return resp;
    } catch (err) {
      throw err;
    }
  }

  Future<Response> authFilesPost(context, url, filePaths,
      {isRetry: true, fileName: "file"}) async {
    try {
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
        Navigator.of(context).popAndPushNamed('/logout');
        return null;
      }
      return resp;
    } catch (err) {
      if (checkAuthErrorResponse(context, err)) {
        Navigator.of(context).popAndPushNamed('/logout');
        return null;
      } else {
        throw err;
      }
    }
  }

  Future<Response> authPut(context, url, data, {isRetry: false}) async {
    try {
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
        Navigator.of(context).popAndPushNamed('/logout');
        return null;
      }
      return resp;
    } catch (err) {
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
        Navigator.of(context).popAndPushNamed('/logout');
        return null;
      }
      return resp;
    } catch (err) {
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
      if (msg != null) {
        if (msg.response != null) {
          if (msg.response.statusCode == 401) {
            return true;
          }
        }
      }
    } catch (err) {}
    return false;
  }

  // Future<bool> trySignInSilently(context) async {
  //   try {
  //     var googleSignIn = await UserService.googleSignIn.signInSilently();
  //     var googleSignInAuthentication = await googleSignIn.authentication;
  //     await storageService.save("token", googleSignInAuthentication.idToken);
  //     await storageService.save(
  //         "access_token", googleSignInAuthentication.accessToken);
  //     UserService.currentUser = googleSignIn;

  //     return true;
  //   } catch (err) {
  //     log(err);
  //   }
  //   return false;
  // }
}
