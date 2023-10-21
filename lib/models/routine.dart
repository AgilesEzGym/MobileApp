import 'exercise.dart';

class Routine {
  int? id;
  String? name;
  String? description;
  int? lenght;
  String? type;
  String? difficulty;
  bool? equipment;
  int? score;
  String? image;
  List<Exercise>? exercise;

  Routine(
      {this.id,
        this.name,
        this.description,
        this.lenght,
        this.type,
        this.difficulty,
        this.equipment,
        this.score,
        this.image,
        this.exercise});

  Routine.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    lenght = json['lenght'];
    type = json['type'];
    difficulty = json['difficulty'];
    equipment = json['equipment'];
    score = json['score'];
    image = json['image'];
    if (json['exercise'] != null) {
      exercise = <Exercise>[];
      json['exercise'].forEach((v) {
        exercise!.add(new Exercise.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['lenght'] = this.lenght;
    data['type'] = this.type;
    data['difficulty'] = this.difficulty;
    data['equipment'] = this.equipment;
    data['score'] = this.score;
    data['image'] = this.image;
    if (this.exercise != null) {
      data['exercise'] = this.exercise!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}