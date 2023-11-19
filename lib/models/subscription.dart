class Subscription {

  String? type;
  String? start;
  String? end;
  String? userId;


  Subscription(
      { this.type, this.start, this.end, this.userId});

  Subscription.fromJson(Map<String, dynamic> json) {

    type = json['type'];
    start = json['start'];
    end = json['end'];
    userId = json['user_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['type'] = this.type;
    data['start'] = this.start;
    data['end'] = this.end;
    data['user_id'] = this.userId;
    return data;
  }
}