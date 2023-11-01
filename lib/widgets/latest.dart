import 'package:flutter/material.dart';

import '../models/routine.dart';
import '../services/routineApi.dart';

class Latest extends StatefulWidget {
  const Latest({Key? key}) : super(key: key);

  @override
  _LatestState createState() => _LatestState();
}

class _LatestState extends State<Latest> {

  List<Routine> rutinas = [];

  @override
  void initState(){
    super.initState();
    fetchRoutines();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 160.0,
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: ListView.builder(scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: rutinas.length,
          itemBuilder: (context, index){
            final rutina = rutinas[index];
            return InkWell(
              onTap: (){
                print("aqui");
              },
              child: Card(

                child: SizedBox(
                    width: 200.0,
                    child: Text(rutina.name.toString())
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
