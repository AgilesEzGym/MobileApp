class registerModel {
  String? name;
  String? surname;
  String? email;
  String? phone;
  String? photo;
  String? password;

  registerModel(
      {this.name,
        this.surname,
        this.email,
        this.phone,
        this.photo,
        this.password});

  registerModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    surname = json['surname'];
    email = json['email'];
    phone = json['phone'];
    photo = json['photo'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['surname'] = this.surname;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['photo'] = this.photo;
    data['password'] = this.password;
    return data;
  }
}