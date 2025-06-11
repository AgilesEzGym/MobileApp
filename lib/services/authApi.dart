import 'dart:convert';
import 'package:http/http.dart' as http;

class authApi {
  static Future<dynamic> login(dynamic creds) async {
    final headers = {"Content-type": "application/json"};
    const url = 'http://10.0.2.2:8080/api/v1/users/login';
    final uri = Uri.parse(url);
    final json = jsonEncode(creds);
    final response = await http.post(uri, headers: headers, body: json);
    return response;
  }

  static Future<dynamic> register(dynamic creds) async {
    final headers = {"Content-type": "application/json"};
    const url = 'http://10.0.2.2:8080/api/v1/users/register';
    final uri = Uri.parse(url);
    final json = jsonEncode(creds);
    //print(json);
    final response = await http.post(uri, headers: headers, body: json);
    return response;
  }

  static Future<dynamic> createSub(dynamic sub) async {
    final headers = {"Content-type": "application/json"};
    const url = 'http://10.0.2.2:8080/api/v1/subscriptions';
    final uri = Uri.parse(url);
    final json = jsonEncode(sub);
    //print(json);
    final response = await http.post(uri, headers: headers, body: json);
    //print(response.body);
    return response.statusCode;
  }
}
