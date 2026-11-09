class PinVerificationModel {
  final bool isValid;
  final int remainingAttempts;
  final String? verificationToken;

  const PinVerificationModel({
    required this.isValid,
    required this.remainingAttempts,
    this.verificationToken,
  });

  factory PinVerificationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PinVerificationModel(
        isValid: false,
        remainingAttempts: 0,
      );
    }

    return PinVerificationModel(
      isValid: json['is_valid'] == true,
      remainingAttempts: int.tryParse(json['remaining_attempts']?.toString() ?? '3') ?? 3,
      verificationToken: json['verification_token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_valid': isValid,
      'remaining_attempts': remainingAttempts,
      'verification_token': verificationToken,
    };
  }
}
