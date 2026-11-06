/// Kesalahan dari layanan REST atau database yang pesannya sudah siap ditampilkan.
class ApiException implements Exception {
  ApiException(this.message, {this.code});

  final String message;

  /// Kode kesalahan asal (misalnya kode PostgreSQL), untuk keperluan debugging.
  final String? code;

  @override
  String toString() => message;
}