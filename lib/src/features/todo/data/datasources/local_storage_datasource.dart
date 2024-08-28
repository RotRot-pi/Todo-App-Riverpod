import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_dto.dart';

class LocalStorageDatasource {
  Future<List<TodoDto>> getTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = prefs.getStringList('todos');
    if (todosJson != null) {
      return todosJson.map((json) => TodoDto.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> saveTodos(List<TodoDto> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = todos.map((todo) => jsonEncode(todo.toJson())).toList();
    await prefs.setStringList('todos', todosJson);
  }
}
