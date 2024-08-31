import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_riverpod/core/di.dart';
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
  final todoRepository = TodoRepositoryImpl(instance<LocalStorageDatasource>());
  return TodoService(todoRepository);
});

class TodoListController extends StateNotifier<AsyncValue<List<Todo>>> {
  final TodoService _todoService;
  final _uuid = const Uuid();
  Set<String> _availableTags = {};
  Set<String> get availableTags => _availableTags;
  TodoListController(this._todoService)
      : super(const AsyncLoading<List<Todo>>()) {
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    try {
      final todos = await _todoService.getTodos();
      final availableTags = await _todoService.getAvailableTags(); // Load tags
      state = AsyncData(todos);
      _availableTags = availableTags; // Update internal state
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }

  Future<void> addTodo(String description, List<String> tags) async {
    final newTodo = Todo(id: _uuid.v4(), description: description, tags: tags);
    try {
      await _todoService.addTodo(newTodo);
      _availableTags.addAll(tags); // Add new tags to available tags
      await _todoService
          .saveAvailableTags(_availableTags); // Persist available tags
      state = state.whenData((todos) => [...todos, newTodo]);
    } catch (e) {
      // Handle error (e.g., show error message)
    }
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

  Future<void> updateTodo(Todo updatedTodo) async {
    state = state.whenData((todos) => [
          for (final todo in todos)
            if (todo.id == updatedTodo.id) updatedTodo else todo
        ]);
    await _todoService.updateTodo(updatedTodo);
  }

  // Tags
  Future<void> addTagToTodo(String todoId, String tag) async {
    final todoToUpdate = state.value!.firstWhere((todo) => todo.id == todoId);
    final updatedTodo =
        todoToUpdate.copyWith(tags: [...todoToUpdate.tags, tag]);

    try {
      await _todoService.updateTodo(updatedTodo); // Save first
      state = state.whenData((todos) => todos.map((todo) {
            if (todo.id == todoId) {
              return updatedTodo;
            }
            return todo;
          }).toList()); // Update state after success
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> removeTagFromTodo(String todoId, String tag) async {
    final todoToUpdate = state.value!.firstWhere((todo) => todo.id == todoId);
    final updatedTodo = todoToUpdate.copyWith(
        tags: todoToUpdate.tags.where((t) => t != tag).toList());

    try {
      await _todoService.updateTodo(updatedTodo); // Save first
      state = state.whenData((todos) => todos.map((todo) {
            if (todo.id == todoId) {
              return updatedTodo;
            }
            return todo;
          }).toList()); // Update state after success
    } catch (e) {
      throw Exception(e);
    }
  }

  List<Todo> filterTodosByTags(List<Todo> todos, List<String> selectedTags) {
    if (selectedTags.isEmpty) {
      return todos; // No filtering if no tags are selected
    }

    return todos.where((todo) {
      return todo.tags.any((tag) => selectedTags.contains(tag));
    }).toList();
  }

  Future<void> addAvailableTag(String tag) async {
    _availableTags.add(tag);
    await _todoService.saveAvailableTags(_availableTags);
    state = state.whenData((todos) => [...todos]); // Trigger a UI update
  }

  Future<void> removeAvailableTag(String tag) async {
    _availableTags.remove(tag);
    await _todoService.saveAvailableTags(_availableTags);
    state = state.whenData((todos) => [...todos]); // Trigger a UI update
  }
}
