import '../model/store_dto.dart';
import '../service/api/api_store_service.dart';
import '../service/base/store_service.dart';
import '../base/store_base.dart';

class StoreRepository implements StoreBase {
  final StoreService _service = ApiStoreService();

  @override
  Future<List<StoreDto>> getStores() async {
    return await _service.getStores();
  }

  @override
  Future<StoreDto> getStoreById(int id) async {
    return await _service.getStoreById(id);
  }
}