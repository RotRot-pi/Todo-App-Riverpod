import 'package:todo_riverpod/src/features/todo/domain/todo_model.dart';
import '../data/todo_repository.dart';

class TodoService {
  final TodoRepository _todoRepository;

  TodoService(this._todoRepository);

  Future<List<Todo>> getTodos() {
    return _todoRepository.getTodos();
  }

  Future<void> addTodo(Todo todo) {
    return _todoRepository.addTodo(todo);
  }

  Future<void> updateTodo(Todo todo) {
    return _todoRepository.updateTodo(todo);
  }

  Future<void> deleteTodo(Todo todo) {
    return _todoRepository.deleteTodo(todo);
  }
}
