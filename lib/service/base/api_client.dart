import 'dart:ui';
import 'package:dio/dio.dart';
import '../../tools/token_manager.dart';
import '../../tools/constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;

  // SİHİRLİ DOKUNUŞ: 401 hatası aldığımızda UI tarafına haber verecek tetikleyici
  static VoidCallback? onUnauthorized;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl, // Azure url'in
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // İstek internete çıkmadan önce telefonun hafızasından token'ı okuyoruz:
          final token = await TokenManager.getToken();

          if (token != null) {
            // Eğer token varsa, isteğin içine ekliyoruz:
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Eğer Token süresi bitmişse ve backend 401 hatası atarsa:
          if (e.response?.statusCode == 401) {
            print("🚨 401 Unauthorized: Token süresi dolmuş veya geçersiz!");

            // 1. Cihazın hafızasındaki o bayatlamış token'ı siliyoruz
            // (TokenManager içindeki silme fonksiyonunun adı neyse onu yazmalısın örn: deleteToken, clearToken vs.)
            await TokenManager.deleteToken();

            // 2. Arayüze "Oturum kapandı, kullanıcıyı dışarı at" sinyalini gönderiyoruz
            if (onUnauthorized != null) {
              onUnauthorized!();
            }
          }
          return handler.next(e);
        },
      ),
    );
  }
}