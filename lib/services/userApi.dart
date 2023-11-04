import 'dart:convert';


import 'package:ezgym/models/profile.dart';
import 'package:http/http.dart' as http;

class UserApi{
  static Future<profileModel> fetchProfile(String id) async{
    var url = 'http://10.0.2.2:3000/profile/$id';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);
    //print(json);
    final results = json;
    final transformed = profileModel.fromJson(json);
    return transformed;

  }
}