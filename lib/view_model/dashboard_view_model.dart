import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/audit_dto.dart';
import '../providers.dart'; // import yolunu kendi projene göre ayarla

class DashboardViewModel extends ChangeNotifier {
  final Ref ref;

  // --- EKRANIN DURUM (STATE) DEĞİŞKENLERİ ---
  List<AuditDto> recentAudits = [];
  int? selectedAuditId;
  bool isLoading = true;
  String? errorMessage;

  DashboardViewModel(this.ref) {
    loadDashboardData();
  }

  // Seçili olan denetimi getirir, yoksa ilk denetimi getirir
  AuditDto? get currentAudit {
    if (recentAudits.isEmpty) return null;
    try {
      return recentAudits.firstWhere((a) => a.id == selectedAuditId);
    } catch (e) {
      return recentAudits.first;
    }
  }

  // --- API'DEN VERİ ÇEKME ---
  Future<void> loadDashboardData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners(); // Ekranı yükleniyor moduna al

    try {
      final audits = await ref.read(auditRepositoryProvider).getRecentAudits();

      recentAudits = audits;
      selectedAuditId = audits.isNotEmpty ? audits.first.id : null;
      isLoading = false;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
    }

    notifyListeners(); // Veriler geldi, ekranı güncelle!
  }

  // Kullanıcı farklı bir ziyarete tıklarsa tetiklenir
  void selectVisit(int auditId) {
    selectedAuditId = auditId;
    notifyListeners(); // Yeni seçime göre grafikleri güncelle
  }

  // --- GRAFİKLER İÇİN DÖNÜŞTÜRÜCÜ FONKSİYONLAR ---

  List<Map<String, dynamic>> getShelfShareData(AuditDto? audit) {
    if (audit == null || audit.brandDistributionJson == null) return [];
    try {
      final Map<String, dynamic> data = jsonDecode(audit.brandDistributionJson!);
      final List<Color> colors = [Colors.blue, Colors.green, Colors.orange, Colors.grey];
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