/// Kesalahan dari layanan REST yang pesannya sudah siap ditampilkan.
class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}