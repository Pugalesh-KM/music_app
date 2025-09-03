import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:music_app/core/constants/routes.dart';
import 'package:music_app/core/database/hive_storage_service.dart';
import 'package:music_app/core/exceptions/http_exception.dart';
import 'package:music_app/core/network/connection/connection_listener.dart';
import 'package:music_app/core/network/model/either.dart';
import 'package:music_app/core/network/model/response.dart' as response;
import 'package:music_app/core/network/network_service.dart';
import 'package:music_app/routes/app_routes.dart';

mixin ExceptionHandlerMixin on NetworkService {
  final HiveService _hiveService = GetIt.instance<HiveService>();
  ///UserPreferences? userPreferences;
  NetworkService? networkService;

  Future<Either<AppException, response.Response>>
  handleException<T extends Object>(
    Future<Response<dynamic>> Function() handler, {
    String endpoint = '',
  }) async {
    var connectionStatus = ConnectionStatusListener.getInstance();

    // Check for internet connection
    if (await connectionStatus.checkConnection()) {
      try {
        Response<dynamic> res = await handler();
        return Right(
          response.Response(
            statusCode: res.statusCode ?? 200,
            data: res.data,
            statusMessage: res.statusMessage,
          ),
        );
      } catch (e) {
        String message = '';
        String identifier = '';
        int statusCode = 0;
        e as DioException;
        if (e.response?.statusCode == 401) {
          log("Unauthorized - Triggering logout...${e.response?.statusCode}");
          logout();

          return Left(
            AppException(
              message: "SESSION_EXPIRY_MSG".tr,
              statusCode: 401,
              identifier: 'Unauthorized at $endpoint',
            ),
          );
        }

        switch (e.runtimeType) {
          case SocketException _:
            e as SocketException;
            message = 'Unable to connect to the server.';
            statusCode = 0;
            identifier = 'Socket Exception ${e.message}\n at  $endpoint';
            break;

          case DioException _:
            message = e.response?.data?['message'] ?? 'Internal Error occurred';
            statusCode = 1;
            identifier = 'DioException ${e.message} \nat  $endpoint';
            break;

          default:
            message = 'Unknown error occurred';
            statusCode = 2;
            identifier = 'Unknown error ${e.toString()}\n at $endpoint';
        }

        return Left(
          AppException(
            message: message,
            statusCode: statusCode,
            identifier: identifier,
          ),
        );
      }
    } else {
      log("No internet");
      return Left(
        AppException(
          message: "NO_INTERNET_MSG".tr,
          statusCode: 0,
          identifier: 'No Internet at $endpoint',
        ),
      );
    }
  }

  void logout() async {
    await _hiveService.clear();
    ///userPreferences?.clearPreferences();
    networkService?.updateHeader({'Authorization': ''});
    nav();
  }

  void nav() {
    navigatorKey.currentState?.context.go(RoutesName.defaultPath);
  }
}
