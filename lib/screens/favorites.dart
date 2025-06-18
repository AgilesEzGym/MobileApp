import 'package:ezgym/screens/routine_details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/routine.dart';
import '../services/routineApi.dart';

class Favourites extends StatefulWidget {
  const Favourites({Key? key}) : super(key: key);

  @override
  _FavouritesState createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  List<Routine> rutinas = [];

  @override
  void initState() {
    super.initState();
    fetchRoutines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites', style: TextStyle(color: Colors.black),),
        centerTitle: true,
        backgroundColor: Colors.white
      ),
      body: Column(
        children: [const Padding(
          padding: EdgeInsets.all(24.0),
          child: Text("Tus rutinas favoritas", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
        ),
          ListView.builder(
            itemCount: rutinas.length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final rutina = rutinas[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(rutina.image.toString()),
                ),
                title: Text("${rutina.name}"),
                subtitle: Text("${rutina.difficulty}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min, // Importante para que no use todo el ancho
                  children: [
                    IconButton(
                      onPressed: () {
                        // Acción del botón de compartir o el que quieras
                        print("Eliminar favorito");
                      },
                      icon: const Icon(CupertinoIcons.heart_fill, color: Colors.red),
                    ),
                    IconButton(
                      onPressed: () {
                        // Acción del botón de compartir o el que quieras
                        //print("Compartir rutina");
                        _showShareDialog(context);
                      },
                      icon: const Icon(CupertinoIcons.share, color: Colors.blue),
                    ),
                  ],
                ),
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoutineDetails(rutina: rutina),
                    ),
                  );
                },
              );
            },
          ),
        ],
      )
    );
  }
  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Share this exercise with friends!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row (
              children: [
                Expanded(
                  child: Text(
                    "routineLink",
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    print("Compartir rutina");
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(CupertinoIcons.share, color: Colors.green),
                    onPressed: () {
                      // Add WhatsApp share logic here
                      // You can use `url_launcher`
                    },
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.share, color: Colors.blue),
                    onPressed: () {
                      // Add WhatsApp share logic here
                      // You can use `url_launcher`
                    },
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.share, color: Colors.orange),
                    onPressed: () {
                      // Add WhatsApp share logic here
                      // You can use `url_launcher`
                    },
                  ),
                ]
            ),
          ]
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      )
    );
  }
  Future<void> fetchRoutines() async{
    final response = await RoutineApi.fetchRoutines();
    setState(() {
      rutinas = response;
    });
  }
}
