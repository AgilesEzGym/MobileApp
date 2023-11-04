import 'package:ezgym/models/subscription.dart';

class profileModel {
  String? name;
  String? surname;
  String? email;
  String? phone;
  String? photo;
  Subscription? subscription;

  profileModel(
      {this.name,
        this.surname,
        this.email,
        this.phone,
        this.photo,
        this.subscription});

  profileModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    surname = json['surname'];
    email = json['email'];
    phone = json['phone'];
    photo = json['photo'];
    subscription = json['subscription'] != null
        ? new Subscription.fromJson(json['subscription'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['surname'] = this.surname;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['photo'] = this.photo;
    if (this.subscription != null) {
      data['subscription'] = this.subscription!.toJson();
    }
    return data;
  }
}