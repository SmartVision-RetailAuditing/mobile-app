/*
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_vision_mobile/tools/token_manager.dart';

import 'model/task_dto.dart'; // Token yöneticisini import et

// 1. Navigation Bar için seçili index (0, 1, 2, 3...)
final navIndexProvider = StateProvider<int>((ref) => 0);

// 2. Dashboard: Seçili Ziyaret ID'si
final dashboardSelectedVisitProvider = StateProvider<int>((ref) => 1);

// 3. Dashboard: Grafik Verileri (Mock Data - Henüz gerçek API'ye bağlanmadı)
final dashboardDataProvider = Provider<Map<String, dynamic>>((ref) {
  return {
    'recentVisits': [
      {'id': 1, 'store': 'Migros MM Kadıköy', 'date': '7 Aralık 2025', 'score': 85, 'availability': 78},
      {'id': 2, 'store': 'Şok Market Üsküdar', 'date': '7 Aralık 2025', 'score': 92, 'availability': 88},
      {'id': 3, 'store': 'CarrefourSA Bağdat', 'date': '6 Aralık 2025', 'score': 78, 'availability': 72},
    ],
    'shelfShareData': [
      {'name': 'Brand A', 'value': 35.0, 'color': const Color(0xFF007AFF)},
      {'name': 'Brand B', 'value': 28.0, 'color': const Color(0xFF34C759)},
      {'name': 'Brand C', 'value': 20.0, 'color': const Color(0xFFFF9500)},
      {'name': 'Others', 'value': 17.0, 'color': const Color(0xFFE5E5EA)},
    ],
    'priceData': [
      {'product': 'A', 'correct': 12.0, 'incorrect': 3.0},
      {'product': 'B', 'correct': 15.0, 'incorrect': 0.0},
      {'product': 'C', 'correct': 8.0, 'incorrect': 4.0},
      {'product': 'D', 'correct': 10.0, 'incorrect': 2.0},
    ],
    'nonCompliantItems': [
      {'product': 'Coca Cola 330ml', 'issue': 'Yanlış raf konumu - Göz seviyesinde olmalı'},
      {'product': 'Fanta 1L', 'issue': 'Planogramda belirtilen sıraya uymuyor'},
      {'product': 'Sprite 2L', 'issue': 'Raf sayısı anlaşmadan az (3 yerine 2)'},
    ],
    'voidAnalysis': [
      {'id': 1, 'type': 'Kritik Boşluk', 'count': 8, 'stockLevel': 'low'},
      {'id': 2, 'type': 'Fazla Stok', 'count': 5, 'stockLevel': 'high'},
      {'id': 3, 'type': 'Orta Seviye Boşluk', 'count': 6, 'stockLevel': 'low'},
    ],
    'complianceIssues': [
      {'id': 1, 'issue': 'Planogram uygulaması hatalı', 'store': 'Migros MM Kadıköy', 'severity': 'high'},
      {'id': 2, 'issue': 'Fiyat etiketleri eksik', 'store': 'CarrefourSA Bağdat', 'severity': 'medium'},
      {'id': 3, 'issue': 'Ürün stoğu düşük', 'store': 'A101 Kartal', 'severity': 'low'},
    ],
  };
});

// 4. Uygulama Teması (Light / Dark mod)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

// 5. Kapı Görevlisi (Auth Checker) - Uygulama açıldığında token kontrolü yapar
final authCheckProvider = FutureProvider<bool>((ref) async {
  final token = await TokenManager.getToken();
  return token != null; // Token varsa true, yoksa false döner
});

final activeTaskProvider = StateProvider<TaskDto?>((ref) => null);
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_vision_mobile/tools/token_manager.dart';
import 'package:smart_vision_mobile/view_model/camera_view_model.dart';
import 'model/task_dto.dart';

// --- YENİ EKLENEN SINIFLARIN İMPORTLARI ---
import 'service/api/api_audit_service.dart';
import 'repository/audit_repository.dart';
import 'view_model/dashboard_view_model.dart';

// ====================================================================
// 1. GENEL UYGULAMA SAĞLAYICILARI (STATE, THEME, AUTH)
// ====================================================================

// Navigation Bar için seçili index (0, 1, 2, 3...)
final navIndexProvider = StateProvider<int>((ref) => 0);

// Uygulama Teması (Light / Dark mod)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

// Kapı Görevlisi (Auth Checker) - Uygulama açıldığında token kontrolü yapar
final authCheckProvider = FutureProvider<bool>((ref) async {
  final token = await TokenManager.getToken();
  return token != null; // Token varsa true, yoksa false döner
});

// Aktif görevi tutan provider
final activeTaskProvider = StateProvider<TaskDto?>((ref) => null);


// ====================================================================
// 2. DASHBOARD VE AUDIT SAĞLAYICILARI (MVVM + REPOSITORY PATTERN)
// ====================================================================

// API Servisi (Ağ isteklerini yapar)
final apiAuditServiceProvider = Provider<ApiAuditService>((ref) {
  return ApiAuditService();
});

// Repository (Veriyi servisten alır, ViewModel'e köprü olur)
final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  final apiService = ref.read(apiAuditServiceProvider);
  return AuditRepository(apiService);
});

// Dashboard ViewModel (Ekranın tüm mantığını ve durumunu yönetir)
final dashboardViewModelProvider = ChangeNotifierProvider<DashboardViewModel>((ref) {
  return DashboardViewModel(ref);
});

// Provider tanımı
final cameraViewModelProvider = StateNotifierProvider<CameraViewModel, void>((ref) {
  return CameraViewModel(ref);
});