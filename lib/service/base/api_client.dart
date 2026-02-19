import 'package:dio/dio.dart';
import '../../tools/token_manager.dart';
import '../../tools/constants.dart'; // BaseUrl'in olduğu dosya

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl, // Azure url'in
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // İŞTE SİHİRLİ KISIM (INTERCEPTOR)
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // İstek internete çıkmadan saniyeler önce buraya düşer.
          // Telefonun hafızasından token'ı okuyoruz:
          final token = await TokenManager.getToken();

          if (token != null) {
            // Eğer token varsa, Swagger'da yaptığın gibi isteğin içine ekliyoruz:
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options); // İsteği yoluna devam ettir
        },
        onError: (DioException e, handler) {
          // Eğer Token süresi bitmişse ve backend 401 hatası atarsa,
          // burada kullanıcıyı otomatik olarak Login sayfasına yönlendirebilirsin.
          if (e.response?.statusCode == 401) {
            print("Token süresi dolmuş veya geçersiz!");
            // İleride buraya logout mantığı eklenebilir.
          }
          return handler.next(e);
        },
      ),
    );
  }
}