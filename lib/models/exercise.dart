class Exercise {
  String? sId;
  String? name;
  String? image;
  int? reps;
  String? video;
  String? description;
  String? routineId;

  Exercise(
      {this.sId,
        this.name,
        this.image,
        this.reps,
        this.video,
        this.description,
        this.routineId});

  Exercise.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    image = json['image'];
    reps = json['reps'];
    video = json['video'];
    description = json['description'];
    routineId = json['routine_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['image'] = this.image;
    data['reps'] = this.reps;
    data['video'] = this.video;
    data['description'] = this.description;
    data['routine_id'] = this.routineId;
    return data;
  }
}