import 'dart:convert';

import 'package:ezgym/models/profile.dart';
import 'package:ezgym/models/subscription.dart';
import 'package:ezgym/services/api_config.dart';
import 'package:http/http.dart' as http;

class UserApi {
  static Future<profileModel> fetchProfile(String id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/users/$id');
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);
    //print(json);
    //final results = json;
    final transformed = profileModel.fromJson(json);
    return transformed;
  }

  static Future<List<Subscription>> getSub(String id) async {
    final uri =
        Uri.parse('${ApiConfig.baseUrl}/api/v1/subscriptions/userId/$id');
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);
    final results = json as List<dynamic>;
    final transformed = results.map((e) {
      return Subscription.fromJson(e);
    }).toList();
    return transformed;
  }

  static Future<bool> updateProfile(String id, profileModel perfil) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/users/$id');

    final jsonBody = jsonEncode(perfil.toUpdateJson());

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonBody,
    );

    if (response.statusCode == 200) {
      print("✅ Actualización exitosa.");
      return true;
    } else {
      print('❌ Error al actualizar: ${response.statusCode}');
      print('Respuesta del servidor: ${response.body}');
      return false;
    }
  }
}
