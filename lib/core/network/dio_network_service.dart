import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_pretty_dio_logger/flutter_pretty_dio_logger.dart';
import 'package:music_app/core/constants/api_constants.dart';
import 'package:music_app/core/exceptions/exception_handler_mixin.dart';
import 'package:music_app/core/exceptions/http_exception.dart';
import 'package:music_app/core/network/model/response.dart' as response;
import 'model/either.dart';
import 'network_service.dart';


class DioNetworkService extends NetworkService with ExceptionHandlerMixin {
  late final Dio _dio;

  DioNetworkService() {
    _dio = Dio();
    // this throws error while running test
    _dio.options = dioBaseOptions;
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          queryParameters: true,
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          showProcessingTime: true,
          showCUrl: true,
          canShowLog: kDebugMode,
        ),
      );
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          return handler.next(response);
        },
      ),
    );
  }

  BaseOptions get dioBaseOptions =>
      BaseOptions(baseUrl: baseUrl, headers: headers);

  @override
  String get baseUrl => ApiConstants.baseUrl;

  @override
  Map<String, Object> get headers => {
    'accept': 'application/json',
    'content-type': 'application/json',
  };

  @override
  Map<String, dynamic>? updateHeader(Map<String, dynamic> data) {
    Map<String, dynamic> header = {...data, ...headers};
    _dio.options.headers = header;
    return header;
  }

  @override
  Future<Either<AppException, response.Response>> post(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    Future<Either<AppException, response.Response>> res = handleException(
      () => _dio.post(endpoint, data: data),
      endpoint: endpoint,
    );
    return res;
  }

  @override
  Future<Either<AppException, response.Response>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    Future<Either<AppException, response.Response>> res = handleException(
      () => _dio.get(endpoint, queryParameters: queryParameters),
      endpoint: endpoint,
    );
    return res;
  }

  @override
  Future<Either<AppException, response.Response>> put(
    String endpoint, {
    Map<String, dynamic>? data,
  }) async {
    Future<Either<AppException, response.Response>> res = handleException(
      () => _dio.put(endpoint, data: data),
      endpoint: endpoint,
    );
    return res;
  }

  @override
  Future<Either<AppException, response.Response>> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    Future<Either<AppException, response.Response>> res = handleException(
      () => _dio.delete(endpoint, queryParameters: queryParameters),
      endpoint: endpoint,
    );
    return res;
  }

  Future<Either<AppException, response.Response>> uploadFile(
    String endpoint,
    FormData formData,
  ) async {
    Future<Either<AppException, response.Response>> res = handleException(
      () => _dio.post(endpoint, data: formData),
      endpoint: endpoint,
    );
    return res;
  }
}
