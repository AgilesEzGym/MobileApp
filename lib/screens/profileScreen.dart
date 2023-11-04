import 'package:flutter/material.dart';
import 'package:ezgym/services/userApi.dart';

import '../models/profile.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  String id = '2';
  profileModel perfil = profileModel(photo: "https://i.pinimg.com/236x/69/dd/d3/69ddd3b32534d35a0874b3a1774dcfa0.jpg");

  @override
  void initState() {
    super.initState();
    fetch();
  }

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
                    perfil.photo.toString()
                  ))
              ),
            ),
            const SizedBox(height: 30),
            Row(children: [
              Container(
              child: const Text('INFORMACIÓN PERSONAL',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
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
                        const SizedBox(height: 10),
                        const Text('Nombre:',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                        const SizedBox(height: 5),
                        Text("${perfil.name}",style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 10),
                        const Text("Correo electrónico:",style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                        const SizedBox(height: 5),
                        Text("${perfil.email}",style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                   Expanded(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        const Text('Apellido:',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                        const SizedBox(height: 5),
                        Text("${perfil.surname}",style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 10),
                        const Text('Número telefónico:',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                        const SizedBox(height: 5),
                        Text("${perfil.phone}",style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Row(children: [
              Container(
              child: const Text('SUSCRIPCIÓN',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
            ),
            ],),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Tipo: ',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                Text("${perfil.subscription?.type}",style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Text('Inicio: ',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                Text("${perfil.subscription?.start}",style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Text('Fin: ',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                Text("${perfil.subscription?.end}",style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 15),
            Row(children: [
              Container(
              child: const Text('MÉTODO DE PAGO',style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
            ),
            ],),
            const SizedBox(height: 10),
             Container(
              height: 50,
              decoration: BoxDecoration(
              border: Border.all(width: 2, color: Colors.grey),
              shape: BoxShape.rectangle,),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Container(
                    height: 30,
                    width: 50,
                    decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    shape: BoxShape.rectangle,
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Visa_Inc._logo.svg/2560px-Visa_Inc._logo.svg.png'
                    ))
                  ),
                 ),
                 const SizedBox(width: 10),
                 const Text('···· ···· ···· 1234',style: TextStyle(fontSize: 16)),
               ]),
            ),
          ],
          ),
      ),
    );
  }

  Future<void> fetch() async{
    final response = await UserApi.fetchProfile(id);
    setState(() {
      perfil = response;
    });
    print(perfil.name);
  }

}
