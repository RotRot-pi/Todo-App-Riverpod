import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_riverpod/src/features/todo/data/datasources/local_storage_datasource.dart';
import 'package:todo_riverpod/src/features/todo/data/todo_repository.dart';
import 'package:uuid/uuid.dart';
import '../../application/todo_service.dart';
import '../../domain/todo_model.dart';

final todoListControllerProvider =
    StateNotifierProvider<TodoListController, AsyncValue<List<Todo>>>((ref) {
  final todoService = ref.read(todoServiceProvider);
  return TodoListController(todoService);
});

final todoServiceProvider = Provider<TodoService>((ref) {
  // In a real app, you might use a different method for dependency injection
  final todoRepository = TodoRepositoryImpl(LocalStorageDatasource());
  return TodoService(todoRepository);
});

class TodoListController extends StateNotifier<AsyncValue<List<Todo>>> {
  final TodoService _todoService;
  final _uuid = const Uuid();

  TodoListController(this._todoService)
      : super(const AsyncLoading<List<Todo>>()) {
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    try {
      final todos = await _todoService.getTodos();
      state = AsyncData(todos);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> addTodo(String description) async {
    final newTodo = Todo(id: _uuid.v4(), description: description);
    state = state.whenData((todos) => [...todos, newTodo]);
    await _todoService.addTodo(newTodo);
  }

  Future<void> toggleTodo(String id) async {
    state = state.whenData((todos) {
      final updatedTodos = todos.map((todo) {
        if (todo.id == id) {
          return todo.copyWith(isCompleted: !todo.isCompleted);
        }
        return todo;
      }).toList();
      return updatedTodos;
    });
    final todoToUpdate = state.value!.firstWhere((todo) => todo.id == id);
    await _todoService.updateTodo(todoToUpdate);
  }

  Future<void> deleteTodo(String id) async {
    final todoToDelete = state.value!.firstWhere((todo) => todo.id == id);
    state = state
        .whenData((todos) => todos.where((todo) => todo.id != id).toList());
    await _todoService.deleteTodo(todoToDelete);
  }
}
