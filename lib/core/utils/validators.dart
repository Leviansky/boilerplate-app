abstract final class Validators {
  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  static final RegExp _indonesiaPhoneRegex = RegExp(
    r'^(?:\+62|62|0)8[1-9][0-9]{6,10}$',
  );

  static final RegExp _pinRegex = RegExp(r'^[0-9]{6}$');

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor ponsel wajib diisi';
    }
    if (!_indonesiaPhoneRegex.hasMatch(value.trim())) {
      return 'Format nomor ponsel tidak valid (contoh: 081234567890)';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi wajib diisi';
    }
    if (value.length < 8) {
      return 'Kata sandi minimal 8 karakter';
    }
    return null;
  }

  static String? validatePin(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN keamanan wajib diisi';
    }
    if (!_pinRegex.hasMatch(value)) {
      return 'PIN harus terdiri dari 6 digit angka';
    }
    return null;
  }
}
