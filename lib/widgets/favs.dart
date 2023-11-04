import 'package:ezgym/screens/routine_details.dart';
import 'package:flutter/material.dart';

import '../models/routine.dart';
import '../services/routineApi.dart';

class Favs extends StatefulWidget {
  const Favs({Key? key}) : super(key: key);

  @override
  _FavsState createState() => _FavsState();
}

class _FavsState extends State<Favs> {

  List<Routine> rutinas = [];

  @override
  void initState(){
    super.initState();
    fetchRoutines();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 175.0,
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: ListView.builder(scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: rutinas.length,
          itemBuilder: (context, index){
            final rutina = rutinas[index];
            return InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => RoutineDetails(rutina: rutina)));
              },
              child: Card(

                child: Column(
                  children: [
                    Image.network(rutina.image.toString(), width: 175),
                    Text("${rutina.name}"),
                    Text("Duracion: ${rutina.lenght} min"),
                    Row(
                      children: [
                        Text("${rutina.score}"),
                        Icon(Icons.star, color: Colors.amber,size: 15,),
                      ],
                    )
                  ],
                ),
              ),
            );
          },)
    );
  }

  Future<void> fetchRoutines() async{
    final response = await RoutineApi.fetchRoutines();
    setState(() {
      rutinas = response;
    });
  }
}
