class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final bool isPinConfigured;
  final bool isBiometricConfigured;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.isPinConfigured,
    required this.isBiometricConfigured,
  });

  factory UserModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const UserModel(
        id: '',
        name: '',
        email: '',
        phoneNumber: '',
        isPinConfigured: false,
        isBiometricConfigured: false,
      );
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      isPinConfigured: json['is_pin_configured'] == true,
      isBiometricConfigured: json['is_biometric_configured'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'is_pin_configured': isPinConfigured,
      'is_biometric_configured': isBiometricConfigured,
    };
  }
}
