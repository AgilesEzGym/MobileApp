
import 'dart:convert';


import 'package:ezgym/models/routine.dart';
import 'package:http/http.dart' as http;

class RoutineApi{
  static Future<List<Routine>> fetchRoutines() async{
    const url = 'http://10.0.2.2:3000/routines';
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
    var url = 'http://10.0.2.2:3000/routines?name_like=$name';
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