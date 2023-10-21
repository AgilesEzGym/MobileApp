import 'package:ezgym/services/routineApi.dart';
import 'package:flutter/material.dart';

import '../models/routine.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Routine> rutinas = [];


  @override
  void initState(){
    super.initState();
    fetchRoutines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EzGym', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: <Widget> [
            Container(
              height: 200.0,
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
                },),
            )

          ],
        ),
      ),
    );
  }


  Future<void> fetchRoutines() async{
    final response = await RoutineApi.fetchRoutines();
    setState(() {
      rutinas = response;
    });
  }
}
