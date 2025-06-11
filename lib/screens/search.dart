import 'package:ezgym/screens/routine_details.dart';
import 'package:flutter/material.dart';
import '../models/routine.dart';
import '../services/routineApi.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  String word = '';
  List<Routine> rutinas = [];
  int maxDuration = 60;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Campo de búsqueda
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: "Inserte su búsqueda",
                  labelText: "Inserte su búsqueda",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
                onChanged: (value) {
                  word = value;
                },
              ),
            ),

            // Slider para duración máxima
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Duración máxima (minutos):"),
                  Slider(
                    value: maxDuration.toDouble(),
                    min: 5,
                    max: 120,
                    divisions: 23,
                    label: "$maxDuration min",
                    onChanged: (value) {
                      setState(() {
                        maxDuration = value.toInt();
                      });
                    },
                  ),
                ],
              ),
            ),

            // Lista de rutinas
            rutinas.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("No hay resultados",
                        style: TextStyle(fontSize: 16)),
                  )
                : ListView.builder(
                    itemCount: rutinas.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final rutina = rutinas[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(rutina.image ?? ''),
                        ),
                        title: Text(rutina.name ?? ''),
                        subtitle:
                            Text("Dificultad: ${rutina.difficulty ?? 'N/A'}"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RoutineDetails(rutina: rutina),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ],
        ),
      ),

      // Botón de búsqueda
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white54,
        child: const Icon(Icons.search, color: Colors.black),
        onPressed: () {
          search();
        },
      ),
    );
  }

  Future<void> search() async {
    if (word.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Por favor ingrese un término de búsqueda")),
      );
      return;
    }

    try {
      final response = await RoutineApi.searchRoutines(word);
      setState(() {
        rutinas = response
            .where((r) => r.lenght != null && r.lenght! <= maxDuration)
            .toList();
      });
    } catch (e) {
      print("Error al buscar rutinas: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al buscar rutinas")),
      );
    }
  }
}
