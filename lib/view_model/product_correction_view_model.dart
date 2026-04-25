// view_model/product_correction_view_model.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../model/audit_dto.dart';
import '../model/catalog_product.dart';
import '../providers.dart';

class CorrectionState {
  final AuditDto audit;
  final int? selectedProductId;
  final bool isSubmitting;
  final String? error;

  CorrectionState({
    required this.audit,
    this.selectedProductId,
    this.isSubmitting = false,
    this.error
  });

  CorrectionState copyWith({
    AuditDto? audit,
    int? selectedProductId,
    bool? isSubmitting,
    String? error
  }) {
    return CorrectionState(
      audit: audit ?? this.audit,
      selectedProductId: selectedProductId ?? this.selectedProductId,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error ?? this.error,
    );
  }
}

class CorrectionViewModel extends StateNotifier<CorrectionState> {
  final Ref ref;

  final Set<int> _modifiedProductIds = {};

  CorrectionViewModel(this.ref, AuditDto initialAudit)
      : super(CorrectionState(audit: initialAudit));

  // --- KULLANICI DROPDOWN'DAN SEÇİM YAPINCA ÇALIŞIR ---
  void updateProductFromCatalog(int productId, CatalogProduct catalogItem) {
    _modifiedProductIds.add(productId);

    final updatedProducts = state.audit.products.map((p) {
      if (p.id == productId) {
        return p.copyWith(
            brandName: catalogItem.brand,
            productName: catalogItem.productName, // YORUMDAN ÇIKARILDI VE AKTİF EDİLDİ
            productCode: catalogItem.originalCode, // YORUMDAN ÇIKARILDI VE AKTİF EDİLDİ
            isManuallyEdited: true
        );
      }
      return p;
    }).toList();

    state = state.copyWith(
      audit: state.audit.copyWith(products: updatedProducts),
    );
  }

  void selectProduct(int id) {
    state = state.copyWith(selectedProductId: id);
  }

  // --- BİTİR BUTONUNA BASILINCA ÇALIŞIR ---
  Future<bool> submitChanges() async {
    if (_modifiedProductIds.isEmpty) return true;

    state = state.copyWith(isSubmitting: true, error: null);
    bool allSuccess = true;

    try {
      final repository = ref.read(auditRepositoryProvider);

      for (var productId in _modifiedProductIds) {
        final updatedProduct = state.audit.products.firstWhere((p) => p.id == productId);

        final success = await repository.updateProductDetails(updatedProduct);

        if (!success) {
          allSuccess = false;
        }
      }

      if (allSuccess) {
        ref.read(dashboardViewModelProvider).loadDashboardData(isRefresh: true);
        _modifiedProductIds.clear();
      } else {
        state = state.copyWith(error: "Bazı ürünler güncellenemedi.");
      }

      state = state.copyWith(isSubmitting: false);
      return allSuccess;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }
}

// KRİTİK GÜNCELLEME: Sayfadan çıkıldığında hafızayı temizlemesi için autoDispose eklendi!
final correctionProvider = StateNotifierProvider.autoDispose.family<CorrectionViewModel, CorrectionState, AuditDto>((ref, audit) {
  return CorrectionViewModel(ref, audit);
});