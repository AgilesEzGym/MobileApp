import 'dart:convert';
import 'package:ezgym/models/routine.dart';
import 'package:ezgym/models/exercise.dart';
import 'package:ezgym/services/routineApi.dart';
import 'package:ezgym/widgets/youtube_video.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../views/pose_detection_view.dart';

class RoutineDetails extends StatefulWidget {
  const RoutineDetails({Key? key, required this.rutina}) : super(key: key);
  final Routine rutina;

  @override
  _RoutineDetailsState createState() => _RoutineDetailsState();
}

class _RoutineDetailsState extends State<RoutineDetails> {
  List<Exercise> ejercicios = [];
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    getExercices();
    loadFavoriteStatus();
  }

  Future<void> loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final favString = prefs.getString('favorites');
    if (favString != null) {
      final List<dynamic> favList = jsonDecode(favString);
      final ids = favList.cast<String>();
      setState(() {
        isFavorite = ids.contains(widget.rutina.sId);
      });
    }
  }

  Future<void> toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favString = prefs.getString('favorites');
    List<String> favIds =
        favString != null ? List<String>.from(jsonDecode(favString)) : [];

    setState(() {
      if (isFavorite) {
        favIds.remove(widget.rutina.sId);
        isFavorite = false;
      } else {
        if (widget.rutina.sId != null) {
          favIds.add(widget.rutina.sId!);
        }
        isFavorite = true;
      }
    });

    await prefs.setString('favorites', jsonEncode(favIds));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.rutina.name}",
            style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
              onPressed: toggleFavorite,
              icon: Icon(
                isFavorite ? CupertinoIcons.heart_solid : CupertinoIcons.heart,
                color: Colors.black,
              )),
          IconButton(
              onPressed: () {
                print("rate");
                showMessage();
              },
              icon: const Icon(Icons.star_border))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Image.network(widget.rutina.image.toString()),
                width: 400,
              ),
              Container(
                child: Text("${widget.rutina.description}"),
                padding: EdgeInsets.only(top: 15),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
                child: Text("Duracion: ${widget.rutina.lenght} minutos"),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                child: Text("Tipo: ${widget.rutina.type}"),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                child: Text("Dificultad: ${widget.rutina.difficulty}"),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                child: Text("Ejercicios: ${ejercicios?.length}"),
              ),
              if (widget.rutina.equipment == true)
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                  child: const Text("Accesorios: Si"),
                ),
              if (widget.rutina.equipment == false)
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                  child: const Text("Accesorios: No"),
                ),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 6, 0, 24),
                child: Row(
                  children: [
                    Text("Calificaión: ${widget.rutina.score}"),
                    const Icon(Icons.star, color: Colors.amber, size: 18)
                  ],
                ),
              ),
              ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: ejercicios.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final Exercise? exercise = ejercicios[index];
                    return SingleChildScrollView(
                      child: Card(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Column(
                                  children: <Widget>[
                                    Image.network(
                                      exercise!.image.toString(),
                                      width: 100,
                                    )
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 0, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${exercise?.name}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text("Repeticiones: ${exercise.reps}")
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 0, 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      PoseDetectorView(
                                                          exercise: exercise),
                                                ));
                                            print("estimacion");
                                          },
                                          icon: const Icon(
                                              Icons.remove_red_eye_outlined)),
                                      IconButton(
                                          onPressed: () {
                                            final videoUrl = exercise.video;
                                            if (videoUrl == null ||
                                                videoUrl.isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'No se encontró un video')),
                                              );
                                              return;
                                            }
                                            final videoId =
                                                YoutubePlayer.convertUrlToId(
                                                    videoUrl);

                                            if (videoId == null) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'URL de video inválida')),
                                              );
                                              return;
                                            }
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                contentPadding: EdgeInsets.zero,
                                                content:
                                                    YoutubePlayerDialogContent(
                                                        videoId: videoId),
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                              Icons.slow_motion_video_sharp))
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

  void showMessage() {
    int rating = 0;
    Routine data = widget.rutina;

    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Califica la rutina'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    data.score = rating;
                    updateRating(data);
                    Navigator.pop(context, 'OK');
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> updateRating(dynamic data) async {
    await RoutineApi.updateRoutine(data);
  }

  Future<void> getExercices() async {
    dynamic res = await RoutineApi.getExercices(widget.rutina.sId.toString());
    setState(() {
      ejercicios = res;
    });
  }
}
