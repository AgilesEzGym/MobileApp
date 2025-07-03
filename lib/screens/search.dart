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
  List<Routine> allRoutines = [];
  List<String> routineTypes = [];
  String selectedType = '';
  int maxDuration = 60;

  @override
  void initState() {
    super.initState();
    loadAllRoutines();
  }

  Future<void> loadAllRoutines() async {
    try {
      final response = await RoutineApi.fetchRoutines();
      setState(() {
        allRoutines = response;
        rutinas = allRoutines;
        routineTypes = allRoutines.map((e) => e.type ?? '').toSet().toList();
      });
    } catch (e) {
      print("Error al cargar rutinas: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al cargar rutinas")),
      );
    }
  }

  void filterRoutines() {
    setState(() {
      rutinas = allRoutines.where((r) {
        final matchesName = word.trim().isEmpty ||
            r.name!.toLowerCase().contains(word.toLowerCase());
        final matchesType = selectedType.isEmpty || r.type == selectedType;
        final matchesLength = r.lenght != null && r.lenght! <= maxDuration;

        return matchesName && matchesType && matchesLength;
      }).toList();
    });
  }

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
                  filterRoutines();
                },
              ),
            ),

            // Dropdown para tipos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Filtrar por tipo",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
                items: routineTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                value: selectedType.isEmpty ? null : selectedType,
                onChanged: (value) {
                  selectedType = value ?? '';
                  filterRoutines();
                },
              ),
            ),

            // Slider para duración máxima
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Duración máxima (segundos):"),
                  Slider(
                    value: maxDuration.toDouble(),
                    min: 5,
                    max: 120,
                    divisions: 23,
                    label: "$maxDuration min",
                    onChanged: (value) {
                      maxDuration = value.toInt();
                      filterRoutines();
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
    );
  }
}
