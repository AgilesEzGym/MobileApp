import 'package:flutter/material.dart';

class Create extends StatefulWidget {
  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Crear cuenta', style: TextStyle(color: Colors.black)),
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black)
      ),
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Form(
                  child: Container(
                    padding: EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Nombre',
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 20.0)
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Apellido',
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 20.0)
                        ),
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
                        TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Confirmar contraseña',
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 20.0)
                        ),
                        MaterialButton(
                          height: 45.0,
                          minWidth: 160.0,
                          color: Colors.indigo.shade900,
                          textColor: Colors.white,
                          child: Text("Continuar"),
                          onPressed: () => {},
                          splashColor: Colors.white,
                        ),
                        Padding(
                            padding: EdgeInsets.only(top: 80.0)
                        ),
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