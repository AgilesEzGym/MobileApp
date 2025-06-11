class profileModel {
  String? sId;
  String? name;
  String? surname;
  String? email;
  String? password;
  String? phone;
  String? photo;

  profileModel(
      {this.sId,
      this.name,
      this.surname,
      this.email,
      this.password,
      this.phone,
      this.photo});

  profileModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    surname = json['surname'];
    email = json['email'];
    password = json['password'];
    phone = json['phone'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['surname'] = this.surname;
    data['email'] = this.email;
    data['password'] = this.password;
    data['phone'] = this.phone;
    data['photo'] = this.photo;
    return data;
  }

  Map<String, dynamic> toUpdateJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (surname != null) data['surname'] = surname;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (photo != null) data['photo'] = photo;
    return data;
  }
}
