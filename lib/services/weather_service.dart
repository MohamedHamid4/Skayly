import 'package:dio/dio.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/failures.dart';
import '../models/weather_data.dart';
import 'weather_cache.dart';

class WeatherFetchResult {
  final WeatherData data;
  final bool fromCache;
  final DateTime? cachedAt;
  const WeatherFetchResult({
    required this.data,
    required this.fromCache,
    this.cachedAt,
  });
}

class WeatherService {
  final Dio _dio;
  final WeatherCache _cache;

  WeatherService({Dio? dio, required WeatherCache cache})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConstants.weatherApiBaseUrl,
              connectTimeout: AppConstants.networkTimeout,
              receiveTimeout: AppConstants.networkTimeout,
            )),
        _cache = cache;

  Future<WeatherFetchResult> fetchByCoords({
    required double lat,
    required double lon,
    required String langCode,
  }) =>
      _fetch(query: '$lat,$lon', langCode: langCode);

  Future<WeatherFetchResult> fetchByCity({
    required String city,
    required String langCode,
  }) =>
      _fetch(query: city, langCode: langCode);

  Future<WeatherFetchResult> _fetch({
    required String query,
    required String langCode,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/forecast.json',
        queryParameters: {
          'key': AppConstants.weatherApiKey,
          'q': query,
          'days': 7,
          'aqi': 'no',
          'alerts': 'no',
          'lang': langCode,
        },
      );
      final raw = response.data;
      if (raw == null) {
        throw const ApiFailure('Empty response from weather service');
      }
      await _cache.write(query, raw);
      return WeatherFetchResult(
        data: WeatherData.fromJson(raw),
        fromCache: false,
      );
    } on DioException catch (e) {
      final cached = _cache.read(query);
      if (cached != null) {
        return WeatherFetchResult(
          data: cached.data,
          fromCache: true,
          cachedAt: cached.cachedAt,
        );
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure();
      }
      final status = e.response?.statusCode;
      String? apiMessage;
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final err = data['error'];
        if (err is Map<String, dynamic>) {
          apiMessage = err['message'] as String?;
        }
      }
      throw ApiFailure(
        apiMessage ?? 'Weather service error',
        statusCode: status,
      );
    } on AppFailure {
      rethrow;
    } catch (e) {
      final cached = _cache.read(query);
      if (cached != null) {
        return WeatherFetchResult(
          data: cached.data,
          fromCache: true,
          cachedAt: cached.cachedAt,
        );
      }
      throw UnknownFailure(e.toString());
    }
  }
}
