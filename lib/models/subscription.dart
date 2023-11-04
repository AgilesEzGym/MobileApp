class Subscription {
  int? id;
  String? type;
  String? start;
  String? end;

  Subscription({this.id, this.type, this.start, this.end});

  Subscription.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    start = json['start'];
    end = json['end'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['start'] = this.start;
    data['end'] = this.end;
    return data;
  }
}