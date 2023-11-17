import 'package:flutter/material.dart';

class Create extends StatefulWidget {
  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> {
  bool isChecked = false;
  int _currentStep = 0;

  List<Step> stepList() => [
    Step(
        title: const Text('Datos personales'),
        isActive: _currentStep >= 0,
        state: StepState.editing,
        content: Column(
          children: const [
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nombres',
              ),
            ),
            SizedBox(
              height: 8,
            ),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Apellidos',
              ),
            ),
            SizedBox(
              height: 8,
            ),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Correo electrónico',
              ),
            ),
            SizedBox(
              height: 8,
            ),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Contraseña',
              ),
            ),
            SizedBox(
              height: 8,
            ),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Confirmar contraseña',
              ),
            ),
            SizedBox(
              height: 8,
            ),
          ],
        ),
    ),
    Step(
        title: Text('Suscripción'),
        isActive: _currentStep >= 1,
        state: StepState.complete,
        content: Center(
          child: SizedBox(
            height: 250,
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(15.0)),
                    child: Container(
                      width: MediaQuery.of(context).size.width*1,
                      height: 120,
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width*0.55,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Plan Mensual',style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(
                                  height: 5,
                                ),
                                Text('Prueba gratuita de 1 semana para nuevos usuarios, '
                                    'posterior al periodo de prueba el usuario '
                                    'debera pagar lo correspondiente por una prueba mensual S/ 20')
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Container(
                              child: Text(
                                'S/. 20',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(15.0)),
                    child: Container(
                      width: MediaQuery.of(context).size.width*1,
                      height: 100,
                      child: Row(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width*0.55,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Plan Anual',style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(
                                  height: 5,
                                ),
                                Text('Ahorra dos meses de suscripcion disfruta la aplicacion por un anio entero '
                                    'pagando por el precio de 10 meses')
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Container(
                              child: Text(
                                'S/. 200',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ))
    ),

  ];

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
      body: Stepper(
        steps: stepList(),
        type: StepperType.horizontal,
        elevation: 0,
        currentStep: _currentStep,
        onStepContinue: (){
          if( _currentStep < (stepList().length -1) ) {
            setState(() {
              _currentStep += 1;
            });
          }
        },
        onStepCancel: (){
          if(_currentStep > 0){
            setState(() {
              _currentStep -= 1;
            });
          }
        },
      ),
    );
  }
}