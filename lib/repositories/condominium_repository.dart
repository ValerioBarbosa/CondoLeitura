import '../models/condominium.dart';

abstract class CondominiumRepository {
  Future<List<Condominium>> findAll({
    String? search,
    CondominiumStatus? status,
  });

  Future<Condominium?> findById(int id);

  Future<int> create(Condominium condominium);

  Future<void> update(Condominium condominium);

  Future<void> archive(int id);

  Future<void> restore(int id);

  Future<void> deletePermanently(int id);

  Future<int> duplicate(int id, String newName);

  Future<void> synchronize(int id);
}
