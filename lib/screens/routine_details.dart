import 'package:ezgym/models/routine.dart';
import 'package:ezgym/models/exercise.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoutineDetails extends StatefulWidget {
  const RoutineDetails({Key? key, required this.rutina}) : super(key: key);
  final Routine rutina;

  @override
  _RoutineDetailsState createState() => _RoutineDetailsState();
}

class _RoutineDetailsState extends State<RoutineDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.rutina.name}", style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(onPressed: (){
            print("aqui");
            
          }, icon: const Icon(
            CupertinoIcons.heart_solid,
            color: Colors.black,
          ))
        ],

      ),
      body: Container(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 24.0,24.0,0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget> [
                Container(child: Text("${widget.rutina.description}")),
                Container(child: Text("Duracion: ${widget.rutina.lenght} minutos"),
                padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),),
                Container(child: Text("Tipo: ${widget.rutina.type}"),
                  padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),),
                Container(child: Text("Dificultad: ${widget.rutina.difficulty}"),
                  padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),),
                Container(child: Text("Ejercicios: ${widget.rutina.exercise?.length}"),
                  padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),),
                if(widget.rutina.equipment == true)
                Container(child: Text("Accesorios: Si"),
                  padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),),
                if(widget.rutina.equipment == false)
                Container(child: Text("Accesorios: No"),
                    padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),),
                Container(child: Row(
                  children: [
                    Text("Calificaión: ${widget.rutina.score}"),
                    Icon(Icons.star, color: Colors.amber, size: 18)
                  ],
                ),
                  padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),),
                ListView.builder(scrollDirection: Axis.vertical,
                    itemCount: widget.rutina.exercise?.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index){
                    final Exercise? exercise = widget.rutina.exercise?[index];
                    return ListTile(
                      title: Text(" ${exercise?.name}"),
                    );
                    })

              ],
            ),
          ),
        ),
      ),
    );
  }
}
