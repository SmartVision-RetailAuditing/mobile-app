import '../model/store_dto.dart';

abstract class StoreBase {
  Future<List<StoreDto>> getStores();
  Future<StoreDto> getStoreById(int id);
}