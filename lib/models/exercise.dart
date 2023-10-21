class Exercise {
  int? id;
  String? name;
  String? image;
  int? reps;
  String? video;

  Exercise({this.id, this.name, this.image, this.reps, this.video});

  Exercise.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    reps = json['reps'];
    video = json['video'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    data['reps'] = this.reps;
    data['video'] = this.video;
    return data;
  }
}