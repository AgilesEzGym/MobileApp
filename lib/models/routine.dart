class Routine {
  String? sId;
  String? name;
  String? description;
  int? lenght;
  String? type;
  String? difficulty;
  bool? equipment;
  int? score;
  String? image;
  bool? isRecommended;
  int? iV;

  Routine(
      {this.sId,
        this.name,
        this.description,
        this.lenght,
        this.type,
        this.difficulty,
        this.equipment,
        this.score,
        this.image,
        this.isRecommended,
        this.iV});

  Routine.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    description = json['description'];
    lenght = json['lenght'];
    type = json['type'];
    difficulty = json['difficulty'];
    equipment = json['equipment'];
    score = json['score'];
    image = json['image'];
    isRecommended = json['isRecommended'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['lenght'] = this.lenght;
    data['type'] = this.type;
    data['difficulty'] = this.difficulty;
    data['equipment'] = this.equipment;
    data['score'] = this.score;
    data['image'] = this.image;
    data['isRecommended'] = this.isRecommended;
    data['__v'] = this.iV;
    return data;
  }
}