import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/audit_dto.dart';
import '../providers.dart';

class DashboardViewModel extends ChangeNotifier {
  final Ref ref;

  List<AuditDto> recentAudits = [];
  int? selectedAuditId;
  bool isLoading = true;
  bool isLoadingMore = false;
  bool isDetailLoading = false; // Detay/SAS URL yüklenirken loader için
  String? errorMessage;

  int _currentPage = 1;
  final int _pageSize = 20;

  DashboardViewModel(this.ref) {
    loadDashboardData(isRefresh: true);
  }

  void clearData() {
    recentAudits = [];
    selectedAuditId = null;
    isLoading = true;
    isDetailLoading = false;
    errorMessage = null;
    _currentPage = 1;
    notifyListeners();
  }

  AuditDto? get currentAudit {
    if (recentAudits.isEmpty) return null;
    return recentAudits.firstWhere(
          (a) => a.id == selectedAuditId,
      orElse: () => recentAudits.first,
    );
  }

  Future<void> loadDashboardData({bool isRefresh = false}) async {
    if (isLoadingMore) return;

    if (isRefresh) {
      _currentPage = 1;
      recentAudits = [];
      isLoading = true;
      errorMessage = null;
      selectedAuditId = null;
    } else {
      isLoadingMore = true;
    }
    notifyListeners();

    try {
      final audits = await ref.read(auditRepositoryProvider).getRecentAudits(_currentPage, _pageSize);

      if (isRefresh) {
        recentAudits = audits;
      } else {
        recentAudits.addAll(audits);
      }

      if (audits.isNotEmpty) {
        _currentPage++;
      }

      if (selectedAuditId == null && recentAudits.isNotEmpty) {
        await selectVisit(recentAudits.first.id);
      }

      isLoading = false;
      isLoadingMore = false;
    } catch (e) {
      isLoading = false;
      isLoadingMore = false;
      errorMessage = "Veriler yüklenemedi: $e";
    }
    notifyListeners();
  }

  Future<void> selectVisit(int auditId) async {
    selectedAuditId = auditId;
    isDetailLoading = true;
    notifyListeners();

    try {
      final detailedAudit = await ref.read(auditRepositoryProvider).getAuditById(auditId);
      int index = recentAudits.indexWhere((a) => a.id == auditId);
      if (index != -1) {
        recentAudits[index] = detailedAudit;
      }
    } catch (e) {
      print("SAS URL hatası: $e");
    } finally {
      isDetailLoading = false;
      notifyListeners();
    }
  }

  // --- GRAFİK DÖNÜŞTÜRÜCÜLER ---

  List<Map<String, dynamic>> getShelfShareData(AuditDto? audit) {
    if (audit == null || audit.brandDistributionJson == null) return [];
    try {
      final Map<String, dynamic> data = jsonDecode(audit.brandDistributionJson!);
      final List<Color> colors = [Colors.blue, Colors.green, Colors.orange, Colors.red, Colors.purple, Colors.grey];
      int index = 0;

      return data.entries.map((e) {
        return {
          'name': e.key,
          'value': (e.value as num).toDouble(),
          'color': colors[index++ % colors.length],
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  List<Map<String, dynamic>> getVoidAnalysis(AuditDto? audit) {
    if (audit == null) return [];
    int missingCount = audit.issues.where((i) => i.issueType == 'MISSING_PRODUCT').length;
    int lowShelfCount = audit.issues.where((i) => i.issueType == 'LOW_SHELF_SHARE').length;

    List<Map<String, dynamic>> voids = [];
    if (missingCount > 0) voids.add({'type': 'Kritik Boşluk', 'stockLevel': 'low', 'count': missingCount});
    if (lowShelfCount > 0) voids.add({'type': 'Düşük Raf Payı', 'stockLevel': 'low', 'count': lowShelfCount});
    return voids;
  }

  List<Map<String, dynamic>> getPriceCompliance(AuditDto? audit) {
    if (audit == null || audit.products.isEmpty) return [];

    final displayProducts = audit.products.take(4).toList();

    return displayProducts.map((p) {
      // ARTIK HATA VERMEYECEK: Çünkü DTO'ya price ekledik.
      double priceValue = p.price ?? 0.0;
      bool isCorrect = priceValue > 0 && p.confidenceScore > 0.90;

      return {
        'product': p.brandName,
        'correct': isCorrect ? 15.0 : 5.0,
        'incorrect': isCorrect ? 0.0 : 10.0,
      };
    }).toList();
  }
}