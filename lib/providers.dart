import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'model/task.dart';

// 1. Navigation Bar için seçili index (0, 1, 2, 3...)
final navIndexProvider = StateProvider<int>((ref) => 0);

// 2. Tasks Ekranı için aktif tab ('active' veya 'history')
final taskTabProvider = StateProvider<String>((ref) => 'active');

// 3. Tasks Ekranı için seçili tarih
final taskDateProvider = StateProvider<DateTime>((ref) => DateTime(2025, 12, 7));

// 4. Profil Verisi (Mock Data - Gerçek uygulamada API'den gelir)
final userProfileProvider = Provider<Map<String, dynamic>>((ref) {
  return {
    'name': 'Ahmet Yılmaz',
    'role': 'Field Worker',
    'id': 'FW-2025-0042',
    'email': 'ahmet.yilmaz@company.com',
    'phone': '+90 555 123 4567',
    'stats': {
      'total': '12',
      'done': '8',
      'pending': '4'
    },
    'performance': {
      'completionRate': 0.92,
      'avgScore': 0.85,
      'visits': '127'
    }
  };
});

// 5. Dashboard: Seçili Ziyaret ID'si
final dashboardSelectedVisitProvider = StateProvider<int>((ref) => 1);

// 6. Dashboard: Grafik Verileri (Mock Data)
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

// 7. Görev Listesi Verisi (Mock Data)
final taskListProvider = Provider<List<Task>>((ref) {
  return [
    Task(
        id: 1,
        marketName: 'Migros MM Kadıköy',
        address: 'Caferağa Mah. Moda Cad. No: 45, Kadıköy',
        taskType: 'Shelf Audit',
        dueDate: '7 Aralık 2025',
        frequency: 'Haftalık ziyaret',
        status: 'Pending'
    ),
    Task(
        id: 2,
        marketName: 'CarrefourSA Bağdat Caddesi',
        address: 'Bağdat Cad. No: 234, Maltepe',
        taskType: 'Price Check',
        dueDate: '7 Aralık 2025',
        frequency: 'Haftalık ziyaret',
        status: 'Pending'
    ),
    Task(
        id: 3,
        marketName: 'Şok Market Üsküdar',
        address: 'Kısıklı Mah. Alemdağ Cad. No: 12, Üsküdar',
        taskType: 'Shelf Audit',
        dueDate: '7 Aralık 2025',
        frequency: 'Haftalık ziyaret',
        status: 'Done'
    ),
    Task(
        id: 4,
        marketName: 'A101 Kartal',
        address: 'Yakacık Mah. Ankara Cad. No: 78, Kartal',
        taskType: 'Panorama',
        dueDate: '7 Aralık 2025',
        frequency: 'Haftalık ziyaret',
        status: 'Pending'
    ),
  ];
});

// Varsayılan olarak Aydınlık (Light) mod başlatıyoruz
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);