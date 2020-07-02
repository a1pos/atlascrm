import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:atlascrm/config/ConfigSettings.dart';

import 'package:atlascrm/services/StorageService.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'UserService.dart';

class ApiService {
  final StorageService storageService = new StorageService();
  final String URLBASE = ConfigSettings.API_URL;
  final int TIMEOUT = 10000;

  Future<Response> publicGet(url, data) async {
    try {
      return await Dio(
        BaseOptions(
          baseUrl: ConfigSettings.API_URL,
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
          baseUrl: ConfigSettings.API_URL,
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
      var currentUser = await UserService.getCurrentUser();
      var token = await currentUser.getIdToken();

      var resp = await Dio(
        BaseOptions(
          baseUrl: URLBASE + "_a1",
          responseType: ResponseType.json,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Firebase ${token.token}",
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
      var currentUser = await UserService.getCurrentUser();
      var token = await currentUser.getIdToken();

      var resp = await Dio(
        BaseOptions(
          baseUrl: URLBASE + "_a1",
          responseType: ResponseType.json,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Firebase ${token.token}",
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
      var currentUser = await UserService.getCurrentUser();
      var token = await currentUser.getIdToken();

      var f = MultipartFile.fromFileSync(filePath);
      var formData = FormData.fromMap({"file": f});

      var resp = await Dio(
        BaseOptions(
          baseUrl: URLBASE + "_a1",
          headers: {
            "Content-Type": "multipart/form-data",
            "Authorization": "Firebase ${token.token}",
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

  Future<Response> authFilesPut(context, url, filePaths,
      {isRetry: true}) async {
    try {
      var currentUser = await UserService.getCurrentUser();
      var token = await currentUser.getIdToken();
      Map dataMap = {};
      var i = 1;
      for (var fPath in filePaths) {
        dataMap["file$i"] = MultipartFile.fromFileSync(fPath);
        i++;
      }
      print(dataMap);
      // var f1 = MultipartFile.fromFileSync(filePaths["file1"]);
      // var f2 = MultipartFile.fromFileSync(filePaths["file2"]);

      // var formData = FormData.fromMap({"file1": f1, "file2": f2});
      var formData = FormData.fromMap(
          {"file1": dataMap["file1"], "file2": dataMap["file2"]});

      var resp = await Dio(
        BaseOptions(
          baseUrl: URLBASE + "_a1",
          headers: {
            "Content-Type": "multipart/form-data",
            "Authorization": "Firebase ${token.token}",
          },
          sendTimeout: TIMEOUT,
        ),
      ).put(url, data: formData);

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
      var currentUser = await UserService.getCurrentUser();
      var token = await currentUser.getIdToken();

      var resp = await Dio(
        BaseOptions(
          baseUrl: URLBASE + "_a1",
          responseType: ResponseType.json,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Firebase ${token.token}",
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
      var currentUser = await UserService.getCurrentUser();
      var token = await currentUser.getIdToken();

      var resp = await Dio(
        BaseOptions(
          baseUrl: URLBASE + "_a1",
          responseType: ResponseType.json,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Firebase ${token.token}",
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
