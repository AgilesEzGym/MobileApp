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
        state: _currentStep <= 0 ? StepState.editing : StepState.complete,
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
    const Step(title: Text('Suscripción'), content: Center(child: Text('Suscripción'),)),
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
      ),
    );
  }
}