import 'dart:convert';

import 'package:ezgym/screens/routine_details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchRoutines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text(
              'Favorites',
              style: TextStyle(color: Colors.black),
            ),
            centerTitle: true,
            backgroundColor: Colors.white),
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text("Tus rutinas favoritas",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                    mainAxisSize: MainAxisSize
                        .min, // Importante para que no use todo el ancho
                    children: [
                      IconButton(
                        onPressed: () {
                          // Acción del botón de compartir o el que quieras
                          print("Eliminar favorito");
                          removeFavorite(rutina.sId!);
                        },
                        icon: const Icon(CupertinoIcons.heart_fill,
                            color: Colors.red),
                      ),
                      IconButton(
                        onPressed: () {
                          // Acción del botón de compartir o el que quieras
                          //print("Compartir rutina");
                          _showShareDialog(context, rutina);
                        },
                        icon: const Icon(CupertinoIcons.share,
                            color: Colors.blue),
                      ),
                    ],
                  ),
                  onTap: () {
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
        ));
  }

  Future<void> removeFavorite(String routineId) async {
    final prefs = await SharedPreferences.getInstance();
    final favString = prefs.getString('favorites');
    List<String> favIds =
        favString != null ? List<String>.from(jsonDecode(favString)) : [];

    setState(() {
      favIds.remove(routineId);
    });

    await prefs.setString('favorites', jsonEncode(favIds));
  }

  void _showShareDialog(BuildContext context, Routine rutina) {
    //final routineLink = "https://ezgym.app/routine/${rutina.sId}"; //  link
    final routineLink = 'https://ezgym.app/routine/${rutina.sId}';
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Share this exercise with friends!"),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "$routineLink",
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: routineLink));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Link copied to clipboard!')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextButton(
                  child: const Text("Share this excercise!"),
                  onPressed: () {
                    SharePlus.instance.share(ShareParams(
                        text: 'Check out this routine! 💪 $routineLink'));
                  },
                ),
              ]),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            ));
  }

  Future<void> fetchRoutines() async {
    final prefs = await SharedPreferences.getInstance();
    final favString = prefs.getString('favorites');
    final Set<String> favIds =
        favString != null ? Set<String>.from(jsonDecode(favString)) : {};

    final response = await RoutineApi.fetchRoutines();

    final List<Routine> favoritas =
        response.where((r) => favIds.contains(r.sId)).toList();

    if (!mounted) return;
    setState(() {
      rutinas = favoritas;
    });
  }
}
