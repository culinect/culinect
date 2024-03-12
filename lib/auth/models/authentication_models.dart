class UsernameModel {
  final String uid;
  final String username;

  UsernameModel({
    required this.uid,
    required this.username,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
    };
  }

  factory UsernameModel.fromMap(Map<String, dynamic> map) {
    return UsernameModel(
      uid: map['uid'],
      username: map['username'],
    );
  }
}

class EmailModel {
  final String uid;
  final String email;

  EmailModel({
    required this.uid,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
    };
  }

  factory EmailModel.fromMap(Map<String, dynamic> map) {
    return EmailModel(
      uid: map['uid'],
      email: map['email'],
    );
  }
}

class PhoneNumberModel {
  final String uid;
  final String phoneNumber;

  PhoneNumberModel({
    required this.uid,
    required this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phoneNumber': phoneNumber,
    };
  }

  factory PhoneNumberModel.fromMap(Map<String, dynamic> map) {
    return PhoneNumberModel(
      uid: map['uid'],
      phoneNumber: map['phoneNumber'],
    );
  }
}
