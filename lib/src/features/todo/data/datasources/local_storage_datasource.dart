import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_dto.dart';

class LocalStorageDatasource {
  final SharedPreferences prefs;

  LocalStorageDatasource(this.prefs);
  Future<List<TodoDto>> getTodos() async {
    final todosJson = prefs.getStringList('todos');
    if (todosJson != null) {
      return todosJson.map((json) => TodoDto.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> saveTodos(List<TodoDto> todos) async {
    final todosJson = todos.map((todo) => jsonEncode(todo.toJson())).toList();
    await prefs.setStringList('todos', todosJson);
  }

  Future<Set<String>> getAvailableTags() async {
    final tagsJson = prefs.getStringList('availableTags');
    if (tagsJson != null) {
      return tagsJson.toSet();
    }
    return {};
  }

  Future<void> saveAvailableTags(Set<String> tags) async {
    await prefs.setStringList('availableTags', tags.toList());
  }
}
