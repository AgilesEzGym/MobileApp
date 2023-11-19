
import 'dart:convert';


import 'package:ezgym/models/routine.dart';
import 'package:http/http.dart' as http;

import '../models/exercise.dart';

class RoutineApi{
  static Future<List<Routine>> fetchRoutines() async{
    const url = 'http://10.0.2.2:8080/api/v1/routines/';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);
    //print(json);
    final results = json as List<dynamic>;
    final transformed = results.map((e) {
      return Routine.fromJson(e);
    }).toList();
    return transformed;

  }

  static Future<List<Routine>> searchRoutines(String name) async{
    var url = 'http://10.0.2.2:8080/api/v1/routines/search/$name';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);
    //print(json);
    final results = json as List<dynamic>;
    final transformed = results.map((e) {
      return Routine.fromJson(e);
    }).toList();
    return transformed;

  }
  
  static Future<void> updateRoutine(Routine data)async{
    final headers = {"Content-type": "application/json"};
    var url = 'http://10.0.2.2:8080/api/v1/routines/';
    final uri = Uri.parse(url);
    final json = data.toJson();
    print(json);
    final response = await http.patch(uri, headers: headers , body: jsonEncode(json));
    print(response.statusCode);
  }

  static Future<List<Exercise>> getExercices( String id) async{
    var url = 'http://10.0.2.2:8080/api/v1/exercise/routine/$id';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);
    print(json);
    final results = json as List<dynamic>;
    final transformed = results.map((e) {
      return Exercise.fromJson(e);
    }).toList();
    return transformed;
  }

  static Future<List<Routine>> getRecommended() async{
    const url = 'http://10.0.2.2:8080/api/v1/routines/recommended';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);
    //print(json);
    final results = json as List<dynamic>;
    final transformed = results.map((e) {
      return Routine.fromJson(e);
    }).toList();
    return transformed;

  }

}