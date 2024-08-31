import 'package:todo_riverpod/src/features/todo/domain/todo_model.dart';
import 'datasources/local_storage_datasource.dart';
import 'models/todo_dto.dart';

abstract class TodoRepository {
  Future<List<Todo>> getTodos();
  Future<void> addTodo(Todo todo);
  Future<void> updateTodo(Todo todo);
  Future<void> deleteTodo(Todo todo);

  Future<Set<String>> getAvailableTags();
  Future<void> saveAvailableTags(Set<String> tags);
}

class TodoRepositoryImpl implements TodoRepository {
  final LocalStorageDatasource _localStorageDatasource;

  TodoRepositoryImpl(this._localStorageDatasource);

  @override
  Future<List<Todo>> getTodos() async {
    final todosDto = await _localStorageDatasource.getTodos();
    return todosDto.map((todoDto) => todoDto.toDomain()).toList();
  }

  @override
  Future<void> addTodo(Todo todo) async {
    final todosDto = await _localStorageDatasource.getTodos();
    todosDto.add(TodoDto.fromDomain(todo));
    await _localStorageDatasource.saveTodos(todosDto);
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    final todosDto = await _localStorageDatasource.getTodos();
    final index = todosDto.indexWhere((dto) => dto.id == todo.id);
    if (index != -1) {
      todosDto[index] = TodoDto.fromDomain(todo);
      await _localStorageDatasource.saveTodos(todosDto);
    }
  }

  @override
  Future<void> deleteTodo(Todo todo) async {
    final todosDto = await _localStorageDatasource.getTodos();
    todosDto.removeWhere((dto) => dto.id == todo.id);
    await _localStorageDatasource.saveTodos(todosDto);
  }

  @override
  Future<Set<String>> getAvailableTags() async {
    return _localStorageDatasource.getAvailableTags();
  }

  @override
  Future<void> saveAvailableTags(Set<String> tags) async {
    return _localStorageDatasource.saveAvailableTags(tags);
  }
}
