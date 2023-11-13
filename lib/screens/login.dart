import 'package:ezgym/screens/create.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
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
                    fontFamily: 'cursive',
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
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> Create()));
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
                              onPressed: (){},
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
}
