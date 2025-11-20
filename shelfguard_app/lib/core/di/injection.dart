import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../storage/local_storage.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Register SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Register Local Storage
  getIt.registerLazySingleton<LocalStorage>(
    () => LocalStorage(getIt<SharedPreferences>()),
  );

  // Register Dio
  getIt.registerLazySingleton<Dio>(() => Dio());

  // Register DioClient
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(getIt<Dio>(), getIt<LocalStorage>()),
  );

  // Auto-generated registrations will be added here by injectable
  // getIt.init();
}
