import 'package:ezgym/models/routine.dart';
import 'package:ezgym/models/exercise.dart';
import 'package:ezgym/services/routineApi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RoutineDetails extends StatefulWidget {
  const RoutineDetails({Key? key, required this.rutina}) : super(key: key);
  final Routine rutina;

  @override
  _RoutineDetailsState createState() => _RoutineDetailsState();
}

class _RoutineDetailsState extends State<RoutineDetails> {

  List<Exercise> ejercicios = [];

  @override
  void initState() {
    super.initState();
    getExercices();
  }

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
            print("fav");
            
          }, icon: const Icon(
            CupertinoIcons.heart_solid,
            color: Colors.black,
          )),
          IconButton(onPressed: (){
            print("rate");
            showMessage();
          }, icon: const Icon(Icons.star_border))
        ],

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 24.0,24.0,0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget> [
              Container(child: Image.network(widget.rutina.image.toString()), width: 400,),
              Container(child: Text("${widget.rutina.description}"),padding: EdgeInsets.only(top: 15),),
              Container(padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
                child: Text("Duracion: ${widget.rutina.lenght} minutos"),),
              Container(padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                child: Text("Tipo: ${widget.rutina.type}"),),
              Container(padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                child: Text("Dificultad: ${widget.rutina.difficulty}"),),
              Container(padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                child: Text("Ejercicios: ${ejercicios?.length}"),),
              if(widget.rutina.equipment == true)
              Container(padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                child: const Text("Accesorios: Si"),),
              if(widget.rutina.equipment == false)
              Container(padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                child: const Text("Accesorios: No"),),
              Container(padding: const EdgeInsets.fromLTRB(0, 6, 0, 24),child: Row(
                children: [
                  Text("Calificaión: ${widget.rutina.score}"),
                  const Icon(Icons.star, color: Colors.amber, size: 18)
                ],
              ),),
              ListView.builder(scrollDirection: Axis.vertical,
                  itemCount: ejercicios.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index){
                  final Exercise? exercise = ejercicios[index];
                  return SingleChildScrollView(
                    child: Card(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Column(
                                children:< Widget> [
                                Image.network(exercise!.image.toString(), width: 100,)
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16,0,0,0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${exercise?.name}", style: const TextStyle(fontWeight: FontWeight.bold),),
                                    Text("Repeticiones: ${exercise.reps}")
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16,0,0,0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    IconButton(onPressed: (){
                                      print("estimacion");
                                    }, icon: const Icon(Icons.remove_red_eye_outlined)),
                                    IconButton(onPressed: (){
                                      print("video");
                                    }, icon: const Icon(Icons.slow_motion_video_sharp))
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                  })

            ],
          ),
        ),
      ),
    );
  }

  void showMessage(){
        int rating = 0;
        Routine data = widget.rutina;
        showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Rate'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 75,
                child: TextField(
                    decoration: const InputDecoration(
                        //hintText: "Inserte su busqueda",
                        labelText: "Rating",
                        //border: OutlineInputBorder(
                        //    borderRadius: BorderRadius.all(Radius.circular(20.0))
                        //)
                    )
                    ,
                    onChanged: (value){
                      rating = int.parse(value);
                      print(rating);
                    },
                  keyboardType: TextInputType.number,

                ),
              ),
              Icon(Icons.star,color: Colors.amber)
              ],

          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'Cancel');
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                data.score= rating;
                updateRating(data);
                Navigator.pop(context, 'OK');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
    Future<void> updateRating(dynamic data) async{
      await RoutineApi.updateRoutine(data);
    }
    
    Future<void> getExercices() async{
      dynamic res = await RoutineApi.getExercices(widget.rutina.sId.toString());
      setState(() {
        ejercicios = res;
      });
    }
}
