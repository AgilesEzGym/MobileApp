import 'package:ezgym/models/subscription.dart';
import 'package:ezgym/screens/workout_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:ezgym/services/userApi.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/profile.dart';
import 'edit_profile_screen.dart'; // asegúrate de tener esta pantalla creada

class Profile extends StatefulWidget {
  const Profile({Key? key, required this.id}) : super(key: key);
  final String id;

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final storage = FlutterSecureStorage();
  late String id = widget.id;
  profileModel perfil = profileModel(
      photo: "https://cdn-icons-png.flaticon.com/512/1361/1361728.png");
  List<Subscription> sub = [];

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    final response = await UserApi.fetchProfile(id);
    final subs = await UserApi.getSub(id);
    if (!mounted) return;
    setState(() {
      perfil = response;
      sub = subs;
    });
    print(perfil.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.fitness_center, color: Colors.black),
            tooltip: 'Historial',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WorkoutHistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            tooltip: 'Editar perfil',
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    id: id,
                    perfil: perfil,
                  ),
                ),
              );
              if (updated == true) {
                fetch(); // Refresca datos al volver si se guardó algo
              }
            },
          ),
        ],
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
                boxShadow: const [
                  BoxShadow(spreadRadius: 2, color: Colors.grey),
                ],
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(perfil.photo.toString()),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: const [
                Text('INFORMACIÓN PERSONAL',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        const Text('Nombre:',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text("${perfil.name}",
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 10),
                        const Text("Correo electrónico:",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text("${perfil.email}",
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        const Text('Apellido:',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text("${perfil.surname}",
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 10),
                        const Text('Número telefónico:',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text("${perfil.phone}",
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                Text('SUSCRIPCIÓN',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Tipo: ',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                if (sub.isNotEmpty)
                  Text("${sub[0].type}", style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Text('Inicio: ',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                if (sub.isNotEmpty)
                  Text("${sub[0].start}", style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Text('Fin: ',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                if (sub.isNotEmpty)
                  Text("${sub[0].end}", style: TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: const [
                Text('MÉTODO DE PAGO',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.grey),
                shape: BoxShape.rectangle,
              ),
              child: Row(
                children: [
                  const SizedBox(width: 15),
                  Container(
                    height: 30,
                    width: 50,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey),
                      shape: BoxShape.rectangle,
                      image: const DecorationImage(
                        image: NetworkImage(
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Visa_Inc._logo.svg/2560px-Visa_Inc._logo.svg.png'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text('···· ···· ···· 1234',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
