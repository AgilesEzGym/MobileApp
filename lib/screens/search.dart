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
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                  decoration: const InputDecoration(
                      hintText: "Inserte su busqueda",
                      labelText: "Inserte su busqueda",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0))
                      )
                  )
                  ,
                  onChanged: (value){

                    word = value;
                  }

              ),
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
                  //trailing: Text('\$${service.price}'),
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
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white54,
        child: const Icon(Icons.search, color: Colors.black,),
        onPressed: (){
          print("searching: $word ");
          search();
        },
      ),
    );
  }

  Future<void> search() async{
    final response = await RoutineApi.searchRoutines(word);
    setState(() {
      rutinas = response;
    });
  }
}
