import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_riverpod/src/features/todo/application/todo_service.dart';
import 'package:todo_riverpod/src/features/todo/data/datasources/local_storage_datasource.dart';
import 'package:todo_riverpod/src/features/todo/data/todo_repository.dart';
import 'package:todo_riverpod/src/features/todo/presentation/controllers/todo_list_controller.dart';

final instance = GetIt.instance;

Future<void> init() async {
  final sharedPref = await SharedPreferences.getInstance();

  instance.registerLazySingleton<SharedPreferences>(() => sharedPref);
  instance.registerLazySingleton<LocalStorageDatasource>(
      () => LocalStorageDatasource(instance<SharedPreferences>()));
  instance.registerSingleton<TodoRepository>(
      TodoRepositoryImpl(instance<LocalStorageDatasource>()));
  instance
      .registerSingleton<TodoService>(TodoService(instance<TodoRepository>()));
  instance.registerSingleton<TodoListController>(
      TodoListController(instance<TodoService>()));
}
