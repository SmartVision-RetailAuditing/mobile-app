import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/audit_dto.dart';
import '../providers.dart';

class DashboardViewModel extends ChangeNotifier {
  final Ref ref;

  // --- EKRANIN DURUM (STATE) DEĞİŞKENLERİ ---
  List<AuditDto> recentAudits = [];
  int? selectedAuditId;
  bool isLoading = true;          // İlk açılış yüklemesi
  bool isLoadingMore = false;     // Sayfalama (yeni sayfa) yüklemesi
  String? errorMessage;

  int _currentPage = 1;           // Mevcut sayfa takibi
  final int _pageSize = 20;       // Her istekte kaç veri geleceği

  DashboardViewModel(this.ref) {
    // Sayfa ilk oluşturulduğunda ilk verileri çek
    loadDashboardData(isRefresh: true);
  }

  // --- YENİ EKLENEN: ÇIKIŞ YAPINCA HAFIZAYI TEMİZLEME FONKSİYONU ---
  void clearData() {
    recentAudits = [];
    selectedAuditId = null;
    isLoading = true;
    errorMessage = null;
    _currentPage = 1;
    notifyListeners();
  }

  // Seçili olan veya varsayılan denetimi döndürür
  AuditDto? get currentAudit {
    if (recentAudits.isEmpty) return null;
    try {
      return recentAudits.firstWhere(
            (a) => a.id == selectedAuditId,
        orElse: () => recentAudits.first,
      );
    } catch (e) {
      return recentAudits.first;
    }
  }

  // --- API'DEN VERİ ÇEKME VE SAYFALAMA ---
  Future<void> loadDashboardData({bool isRefresh = false}) async {
    // Zaten bir yükleme varsa işlemi başlatma
    if (isLoadingMore) return;

    if (isRefresh) {
      _currentPage = 1;
      recentAudits = [];
      isLoading = true;
      errorMessage = null;
    } else {
      isLoadingMore = true;
    }
    notifyListeners();

    try {
      // Repository fonksiyonunu sayfa ve boyut parametreleriyle çağırıyoruz
      final audits = await ref.read(auditRepositoryProvider).getRecentAudits(
          _currentPage, _pageSize
      );

      if (isRefresh) {
        recentAudits = audits;
      } else {
        recentAudits.addAll(audits); // Yeni gelenleri mevcut listenin sonuna ekle
      }

      // Veri geldiyse bir sonraki sayfa numarasını hazırla
      if (audits.isNotEmpty) {
        _currentPage++;
      }

      // Başlangıçta seçili bir audit yoksa ilkini seç
      if (selectedAuditId == null && recentAudits.isNotEmpty) {
        selectedAuditId = recentAudits.first.id;
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

  // Kullanıcı listeden başka bir ziyarete tıkladığında
  void selectVisit(int auditId) {
    selectedAuditId = auditId;
    notifyListeners();
  }

  // --- GRAFİKLER İÇİN DÖNÜŞTÜRÜCÜ FONKSİYONLAR ---

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
    if (missingCount > 0) {
      voids.add({'type': 'Kritik Boşluk', 'stockLevel': 'low', 'count': missingCount});
    }
    if (lowShelfCount > 0) {
      voids.add({'type': 'Düşük Raf Payı', 'stockLevel': 'low', 'count': lowShelfCount});
    }
    return voids;
  }

  List<Map<String, dynamic>> getPriceCompliance(AuditDto? audit) {
    if (audit == null || audit.products.isEmpty) return [];

    final displayProducts = audit.products.take(4).toList();

    return displayProducts.map((p) {
      double price = p.price ?? 0;
      bool isCorrect = price > 0 && p.confidenceScore > 0.90;

      return {
        'product': p.brandName,
        'correct': isCorrect ? 15.0 : 5.0,
        'incorrect': isCorrect ? 0.0 : 10.0,
      };
    }).toList();
  }
}