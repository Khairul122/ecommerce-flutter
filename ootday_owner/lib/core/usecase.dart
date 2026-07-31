/// Kontrak dasar untuk use case di layer domain: satu use case = satu aksi
/// bisnis, dipanggil dari provider (presentation) lewat `call(params)`.
abstract class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Dipakai oleh use case yang tidak butuh parameter.
class NoParams {
  const NoParams();
}
