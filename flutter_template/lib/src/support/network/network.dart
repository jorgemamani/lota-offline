// ignore_for_file: constant_identifier_names

// Dart imports:
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// Package imports:
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

// Project imports:
import 'content_type_enum.dart';
import 'http_method_enum.dart';
import 'network_request.dart';
import 'network_response.dart';

enum HttpCodesEnum {
  NoInternetConnection(0),
  s204_NoContent(204),
  e400_BadRequest(400),
  e401_Unauthorized(401),
  e402_PaymentRequired(402),
  e403_Forbidden(403),
  e404_NotFound(404),
  e405_MethodNotAllowed(405),
  e406_NotAcceptable(406),
  e407_ProxyAuthenticationRequired(407),
  e408_RequestTimeout(408),
  e409_Conflict(409),
  e410_Gone(410),
  e411_LengthRequired(411),
  e412_PreconditionFailed(412),
  e413_PayloadTooLarge(413),
  e414_URITooLong(414),
  e415_UnsupportedMediaType(415),
  e416_RangeNotSatisfiable(416),
  e417_ExpectationFailed(417),
  e418_ImAteapot(418),
  e422_UnprocessableEntity(422),
  e425_TooEarly(425),
  e426_UpgradeRequired(426),
  e428_PreconditionRequired(428),
  e429_TooManyRequests(429),
  e431_RequestHeaderFieldsTooLarge(431),
  e451_UnavailableForLegalReasons(451),
  e500_InternalServerError(500),
  e501_NotImplemented(501),
  e502_BadGateway(502),
  e503_ServiceUnavailable(503),
  e504_GatewayTimeout(504),
  e505_HTTPVersionNotSupported(505),
  e506_VariantAlsoNegotiates(506),
  e507_InsufficientStorage(507),
  e508_LoopDetected(508),
  e510_NotExtended(510),
  e511_NetworkAuthenticationRequired(511);

  final int value;
  const HttpCodesEnum(this.value);
}

class HttpResult implements Exception {
  final String msg;
  final HttpCodesEnum type;
  final List<ErrorResponse> errors;

  const HttpResult({
    this.msg = "",
    required this.type,
    this.errors = const [],
  });

  @override
  String toString() => 'Error: $msg';
}

class Network {
  static final Network _singleton = Network._internal();
  static const maxConnectionAttempts = 1;
  String? token;
  //var _dioCacheManager = DioCacheManager(CacheConfig());

  final _options = CacheOptions(
    store: MemCacheStore(),
    policy: CachePolicy.request,
    hitCacheOnErrorExcept: [401, 403],
    maxStale: const Duration(minutes: 5),
    priority: CachePriority.normal,
    cipher: null,
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
    allowPostMethod: false,
  );

  factory Network() {
    return _singleton;
  }

  Network._internal();

  setToken(String token) {
    this.token = token;
  }

  Future checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return;
      }
    } catch (e) {
      throw const HttpResult(type: HttpCodesEnum.NoInternetConnection);
    }

    throw const HttpResult(type: HttpCodesEnum.NoInternetConnection);
  }

  Future<NetworkResponse?> callApi(NetworkRequest request) async {
    try {
      await checkInternetConnection();
      Response? response;

      switch (request.httpMethod) {
        case HttpMethodEnum.httpGet:
          response = await _get(request);
          break;
        case HttpMethodEnum.httpPost:
          response = await _post(request);
          break;
        case HttpMethodEnum.httpPut:
          response = await _put(request);
          break;
        case HttpMethodEnum.httpDelete:
          response = await _delete(request);
          break;
      }

      return _processResult(response!);
    } on DioException catch (er) {
      _processStatusCode(er.response);
    } on Exception {
      rethrow;
    }

    return null;
  }

  Object? _buildRequestData({
    required ContentTypeEnum contentTypeEnum,
    String? jsonBody,
    Map<String, File>? files,
  }) {
    Map<String, dynamic> formData = {};
    switch (contentTypeEnum) {
      case ContentTypeEnum.applicationJsonUtf8:
        return jsonBody;
      case ContentTypeEnum.multipartDataForm:
        if (jsonBody != null) {
          formData["application/json"] = jsonBody;
        }
        if ((files ?? {}).isNotEmpty) {
          for (String fileCode in files!.keys) {
            formData[fileCode] = MultipartFile.fromFile(
              files[fileCode]!.path,
              contentType: MediaType(
                "image",
                extension(files[fileCode]!.path).isEmpty
                    ? "jpg"
                    : extension(files[fileCode]!.path),
              ),
            );
          }
        }
        return FormData.fromMap(formData);
    }
  }

  String getContentTypeString(ContentTypeEnum contentTypeEnum) {
    switch (contentTypeEnum) {
      case ContentTypeEnum.applicationJsonUtf8:
        return "application/json charset=utf-8";
      case ContentTypeEnum.multipartDataForm:
        return "multipart/form-data";
    }
  }

  Future<Response?> _get(NetworkRequest request) async {
    for (int attempt = 0;
        attempt <
            ((request.httpMethod == HttpMethodEnum.httpGet &&
                    request.enableRepeat)
                ? maxConnectionAttempts
                : 1);) {
      Options options = Options();
      options.headers = {"authorization": 'Bearer $token'};
      Dio dio = Dio();

      if (request.enableCache) {
        dio.interceptors.add(DioCacheInterceptor(options: _options));
      }

      switch (request.responseType) {
        case ResponseType.bytes:
          return await Dio()
              .get<Uint8List>(request.url, options: options)
              .timeout(Duration(seconds: request.timeOutInSeconds));

        default:
          return await Dio()
              .get<String>(request.url, options: options)
              .timeout(Duration(seconds: request.timeOutInSeconds));
      }
    }

    return null;
  }

  Future<Response> _post(NetworkRequest request) async {
    Map<String, String> optionHeaders = {
      'authorization': 'Bearer $token',
      'content-type': getContentTypeString(request.contentType),
    };

    Options options = Options(headers: optionHeaders);
    Object? data = _buildRequestData(
      contentTypeEnum: request.contentType,
      jsonBody: request.jsonBody,
      files: request.files,
    );
    switch (request.responseType) {
      case ResponseType.bytes:
        return await Dio()
            .post<Uint8List>(request.url, data: data, options: options)
            .timeout(Duration(seconds: request.timeOutInSeconds));

      default:
        return await Dio()
            .post<String>(request.url, data: data, options: options)
            .timeout(Duration(seconds: request.timeOutInSeconds));
    }
  }

  Future<Response> _put(NetworkRequest request) async {
    Map<String, String> optionHeaders = {
      'authorization': 'Bearer $token',
      'content-type': getContentTypeString(request.contentType),
    };

    Options options = Options(headers: optionHeaders);
    Object? data = _buildRequestData(
      contentTypeEnum: request.contentType,
      jsonBody: request.jsonBody,
      files: request.files,
    );
    switch (request.responseType) {
      case ResponseType.bytes:
        return await Dio()
            .put<Uint8List>(request.url, data: data, options: options)
            .timeout(Duration(seconds: request.timeOutInSeconds));

      default:
        return await Dio()
            .put<String>(request.url, data: data, options: options)
            .timeout(Duration(seconds: request.timeOutInSeconds));
    }
  }

  Future<Response> _delete(NetworkRequest request) async {
    Map<String, String> optionHeaders = {
      'authorization': 'Bearer $token',
      'content-type': getContentTypeString(request.contentType),
    };

    Options options = Options(headers: optionHeaders);
    Object? data = _buildRequestData(
      contentTypeEnum: request.contentType,
      jsonBody: request.jsonBody,
      files: request.files,
    );
    switch (request.responseType) {
      case ResponseType.bytes:
        return await Dio()
            .delete<Uint8List>(request.url, data: data, options: options)
            .timeout(Duration(seconds: request.timeOutInSeconds));

      default:
        return await Dio()
            .delete<String>(request.url, data: data, options: options)
            .timeout(Duration(seconds: request.timeOutInSeconds));
    }
  }

  NetworkResponse? _processResult(Response? response) {
    NetworkResponse result = NetworkResponse();

    if (response != null) {
      _processStatusCode(response);

      result.response = response.data;
      result.statusCode = response.statusCode;
      result.message = response.statusMessage;
      return result;
    }

    return null;
  }

  _processStatusCode(Response? response) {
    if (response != null) {
      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode != null) {
        throw HttpResult(
          type: getErrorEnum(response.statusCode!),
          msg: response.statusMessage ?? "",
          errors: response.data != null
              ? List<ErrorResponse>.from(
                  jsonDecode(response.data!)["errors"].map(
                    (item) => ErrorResponse.fromJson(item),
                  ),
                )
              : [],
        );
      }
    }
  }

  HttpCodesEnum getErrorEnum(int code) {
    try {
      return HttpCodesEnum.values.firstWhereOrNull(
              (httpCodesEnum) => httpCodesEnum.value == code) ??
          HttpCodesEnum.e500_InternalServerError;
    } catch (e) {
      return HttpCodesEnum.e500_InternalServerError;
    }
  }
}

class ErrorResponse {
  String? code;
  String? exception;
  String? message;

  ErrorResponse({
    this.code,
    this.exception,
    this.message,
  });

  ErrorResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    exception = json['exception'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'exception': exception,
        'message': message,
      };
}
