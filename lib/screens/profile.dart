import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        height: 610.0,
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(width: 3, color: Colors.white),
                boxShadow: [
                  BoxShadow(
                    spreadRadius: 2,
                    color: Colors.grey,
                  )
                ],
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(
                    'https://cdn.pixabay.com/photo/2018/06/09/13/06/girl-3464356_1280.jpg'
                  ))
              ),
            ),
            SizedBox(height: 30),
            Row(children: [
              Container(
              child: Text('INFORMACIÓN PERSONAL',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
            ),
            ],),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text('Nombre:',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                        SizedBox(height: 5),
                        Text('María Elena',style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                        Text('Correo electrónico:',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                        SizedBox(height: 5),
                        Text('maria.arias@gmail.com',style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                   Expanded(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),
                        Text('Apellido:',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                        SizedBox(height: 5),
                        Text('Arias Gonzales',style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                        Text('Número telefónico:',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                        SizedBox(height: 5),
                        Text('+51 987 654 321',style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Row(children: [
              Container(
              child: Text('SUSCRIPCIÓN',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
            ),
            ],),
            SizedBox(height: 10),
            Row(
              children: [
                Text('Tipo: ',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                Text('Mensual',style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Text('Inicio: ',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                Text('09/10/2023',style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Text('Fin: ',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                Text('09/11/2023',style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 15),
            Row(children: [
              Container(
              child: Text('MÉTODO DE PAGO',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
            ),
            ],),
            SizedBox(height: 10),
             Container(
              height: 50,
              decoration: BoxDecoration(
              border: Border.all(width: 2, color: Colors.grey),
              shape: BoxShape.rectangle,),
              child: Row(
                children: [
                  SizedBox(width: 10),
                  Container(
                    height: 30,
                    width: 50,
                    decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Visa_Inc._logo.svg/2560px-Visa_Inc._logo.svg.png'
                    ))
                  ),
                 ),
                 SizedBox(width: 10),
                 Text('···· ···· ···· 1234',style: TextStyle(fontSize: 16)),
               ]),
            ),
          ],
          ),
      ),
    );
  }
}
