import 'dart:convert';

import 'package:ezgym/models/loginModel.dart';
import 'package:ezgym/screens/create.dart';
import 'package:ezgym/screens/home.dart';
import 'package:ezgym/services/authApi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../widgets/nav.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isChecked = false;
  final storage = FlutterSecureStorage();
  late String _email;
  late  String _password;
  late loginModel creds;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(

        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(
                image: AssetImage("lib/assets/Logo.JPG"),
                height: 120.0,
              ),
              Padding(
                  padding: EdgeInsets.only(top: 20.0)
              ),
              Text(
                'EzGym',
                style: TextStyle(
                    fontSize: 35.0
                ),
              ),
              Form(
                  child: Container(
                    padding: EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Correo electrónico',
                          ),
                          onChanged: (valor){
                            _email  = valor;
                          }
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 20.0)
                        ),
                        TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Contraseña',
                          ),
                          onChanged: (valor){
                            _password  = valor;
                          },
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 20.0)
                        ),
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Checkbox(
                              value: isChecked,
                              activeColor: Colors.indigo.shade900,
                              onChanged: (bool? value) {
                                setState(() {
                                  isChecked = value!;
                                });
                              },
                            ),
                            Text(
                              'Recordarme',
                              style: TextStyle(
                                  fontFamily: 'FredokaOne'
                              ),
                            ),
                          ],
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 20.0)
                        ),
                        MaterialButton(
                          height: 45.0,
                          minWidth: 160.0,
                          color: Colors.indigo.shade900,
                          textColor: Colors.white,
                          child: Text("Iniciar sesión"),
                          onPressed: () {
                            loggear();
                          },
                          splashColor: Colors.white,
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 20.0)
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            MaterialButton(
                              onPressed: (){},
                              child: Text(
                                '¿Olvidaste tu contraseña?',
                                style: TextStyle(
                                    fontFamily: 'FredokaOne'
                                ),
                              ),
                            )
                          ],
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 80.0)
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '¿Aún no tienes una cuenta?',
                              style: TextStyle(
                                  fontFamily: 'FredokaOne'
                              ),
                            ),
                            MaterialButton(
                              onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=> Create()));
                              },
                              child: Text(
                                'Registrate',
                                style: TextStyle(
                                    fontFamily: 'FredokaOne'
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ))
            ],
          )
        ],
      ),
    );
  }

  void navigate(){
    Navigator.push(context, MaterialPageRoute(builder: (context)=> Nav()));
  }

  void showMessage(){
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Error'),
        content: const Text('Email o contraseña incorrectos'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'OK');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  Future<void> loggear() async{

    creds = loginModel(email: _email, password: _password);
    var json = creds.toJson();

    var response = await authApi.login(json);
    var decoded = jsonDecode(response.body);

    if(response.statusCode == 200){
      print(decoded['id']);
      await storage.write(key: 'id', value: decoded['id']);
      navigate();
    }
    else{
      showMessage();
    }

  }


}


