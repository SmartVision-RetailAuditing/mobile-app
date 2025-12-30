import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_vision_mobile/providers.dart';
import 'package:smart_vision_mobile/tools/AppColors.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedVisitId = ref.watch(dashboardSelectedVisitProvider);
    final data = ref.watch(dashboardDataProvider);

    final recentVisits = List<Map<String, dynamic>>.from(data['recentVisits']);
    final shelfShareData = List<Map<String, dynamic>>.from(data['shelfShareData']);
    final priceData = List<Map<String, dynamic>>.from(data['priceData']);
    final nonCompliantItems = List<Map<String, dynamic>>.from(data['nonCompliantItems']);
    final voidAnalysis = List<Map<String, dynamic>>.from(data['voidAnalysis']);
    final complianceIssues = List<Map<String, dynamic>>.from(data['complianceIssues']);

    final currentVisit = recentVisits.firstWhere(
          (v) => v['id'] == selectedVisitId,
      orElse: () => recentVisits[0],
    );

    // --- TEMA AYARLARI ---
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color kBgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color kTextColor = Theme.of(context).textTheme.bodyMedium!.color!;
    final Color kCardColor = Theme.of(context).cardColor; // Kart Rengi
    final Color kPrimaryBlue = AppColors.colorPrimaryBlue;
    final Color kGreen = AppColors.colorGreen;
    final Color kOrange = AppColors.colorOrange;
    final Color kRed = AppColors.colorRed;

    // Gri yazılar koyu modda daha açık gri olmalı
    final Color kGrayText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: kBgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, kTextColor, kCardColor, isDark),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Listeyi ve aksiyonu yöneten widget
                  _buildRecentVisitsList(ref, recentVisits, selectedVisitId, kPrimaryBlue, kBgColor, kTextColor, kCardColor, isDark),

                  const SizedBox(height: 16),

                  // Seçili Mağaza Bilgisi
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kPrimaryBlue.withOpacity(0.1),
                      border: Border(left: BorderSide(color: kPrimaryBlue, width: 4)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gösterilen Analizler', style: TextStyle(color: kGrayText, fontSize: 13)),
                        Text(currentVisit['store'], style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  _buildShelfShareChart(shelfShareData, kPrimaryBlue, kTextColor, kCardColor, isDark, kGrayText),
                  const SizedBox(height: 16),
                  _buildAvailabilityGauge(currentVisit, kPrimaryBlue, kTextColor, kCardColor, isDark, kGrayText),
                  const SizedBox(height: 16),
                  _buildPlanogramCompliance(nonCompliantItems, kTextColor, kBgColor, kGreen, kRed, kCardColor, isDark, kGrayText),
                  const SizedBox(height: 16),
                  _buildPriceComplianceChart(priceData, kPrimaryBlue, kGreen, kRed, kOrange, kCardColor, isDark, kGrayText),
                  const SizedBox(height: 16),
                  _buildVoidAnalysis(voidAnalysis, kTextColor, kPrimaryBlue, kRed, kCardColor, isDark, kGrayText),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 1. HEADER ---
  Widget _buildHeader(BuildContext context, Color kTextColor, Color kCardColor, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 16,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        color: kCardColor, // DÜZELTİLDİ: Dinamik renk
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        'Dashboard',
        style: TextStyle(color: kTextColor, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  // --- 3. RECENT VISITS (RIVERPOD ILE) ---
  Widget _buildRecentVisitsList(
      WidgetRef ref,
      List<Map<String, dynamic>> recentVisits,
      int selectedVisitId,
      Color kPrimaryBlue,
      Color kBgColor,
      Color kTextColor,
      Color kCardColor, // YENİ
      bool isDark // YENİ
      ) {
    return _buildCard(
      title: 'Son Ziyaretler',
      kPrimaryBlue: kPrimaryBlue,
      kTextColor: kTextColor,
      kCardColor: kCardColor, // YENİ
      isDark: isDark, // YENİ
      child: Column(
        children: recentVisits.map((visit) {
          final isSelected = selectedVisitId == visit['id'];
          final score = visit['score'] as int;

          Color badgeColorBg = score >= 85 ? Colors.green.shade100 : (score >= 70 ? Colors.orange.shade100 : Colors.red.shade100);
          Color badgeColorText = score >= 85 ? Colors.green.shade700 : (score >= 70 ? Colors.orange.shade700 : Colors.red.shade700);

          if (isSelected) {
            badgeColorBg = Colors.white.withOpacity(0.2);
            badgeColorText = Colors.white;
          }

          return GestureDetector(
            onTap: () {
              ref.read(dashboardSelectedVisitProvider.notifier).state = visit['id'];
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // Seçili değilse kBgColor (Scaffold rengi) kullanılır, kCardColor değil
                // Böylece kartın içinde ayırt edilebilir olur.
                color: isSelected ? kPrimaryBlue : kBgColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected ? [BoxShadow(color: kPrimaryBlue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : [],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visit['store'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : kTextColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 12, color: isSelected ? Colors.white70 : Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              visit['date'],
                              style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColorBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$score%',
                      style: TextStyle(color: badgeColorText, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: isSelected ? Colors.white60 : Colors.grey.shade400, size: 18),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- 4. SHELF SHARE ---
  Widget _buildShelfShareChart(List<Map<String, dynamic>> data, Color kPrimaryBlue, Color kTextColor, Color kCardColor, bool isDark, Color kGrayText) {
    return _buildCard(
      title: 'Share of Shelf',
      icon: Icons.pie_chart_outline,
      kPrimaryBlue: kPrimaryBlue,
      kTextColor: kTextColor,
      kCardColor: kCardColor,
      isDark: isDark,
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: data.map((item) {
                  return PieChartSectionData(
                    color: item['color'],
                    value: item['value'],
                    title: '${item['value'].toInt()}%',
                    radius: 60,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: data.map((item) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: item['color'], shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(item['name'], style: TextStyle(color: kGrayText, fontSize: 12)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- 5. AVAILABILITY GAUGE ---
  Widget _buildAvailabilityGauge(Map<String, dynamic> currentVisit, Color kPrimaryBlue, Color kTextColor, Color kCardColor, bool isDark, Color kGrayText) {
    double percentage = (currentVisit['availability'] ?? 78) / 100.0;

    return _buildCard(
      title: 'Bulunabilirlik Oranı',
      icon: Icons.inventory_2_outlined,
      kPrimaryBlue: kPrimaryBlue,
      kTextColor: kTextColor,
      kCardColor: kCardColor,
      isDark: isDark,
      // DEĞİŞİKLİK BURADA: Column'u SizedBox ile sarmalayıp genişliğini sonsuz yapıyoruz
      child: SizedBox(
        width: double.infinity, // Kartın tamamına yayılmasını sağlar
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center, // Bu zaten varsayılandır, yazmasan da olur
          children: [
            const SizedBox(height: 10),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 12,
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  ),
                ),
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: percentage,
                    strokeWidth: 12,
                    color: kPrimaryBlue,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(percentage * 100).toInt()}%',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: kTextColor),
                    ),
                    Text('Bulunabilir', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Analiz tamamlandı. Ürünler rafta mevcut.',
              style: TextStyle(color: kGrayText, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // --- 6. PLANOGRAM COMPLIANCE ---
  Widget _buildPlanogramCompliance(List<Map<String, dynamic>> nonCompliantItems, Color kTextColor, Color kBgColor, Color kGreen, Color kRed, Color kCardColor, bool isDark, Color kGrayText) {
    return _buildCard(
      title: 'Planogram Compliance',
      icon: Icons.bar_chart,
      kTextColor: kTextColor,
      kCardColor: kCardColor,
      isDark: isDark,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Genel Uyumluluk', style: TextStyle(color: kGrayText, fontSize: 13)),
              Text('82%', style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.82,
              minHeight: 10,
              backgroundColor: kBgColor,
              color: kGreen,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Anlaşmaya Uymayan Maddeler:', style: TextStyle(color: kGrayText, fontSize: 13)),
          ),
          const SizedBox(height: 8),
          ...nonCompliantItems.map((item) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kRed.withOpacity(0.05),
              border: Border.all(color: kRed.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline, color: kRed, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['product'], style: TextStyle(color: kTextColor, fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(item['issue'], style: TextStyle(color: kRed, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // --- 7. PRICE COMPLIANCE ---
  Widget _buildPriceComplianceChart(List<Map<String, dynamic>> priceData, Color kPrimaryBlue, Color kGreen, Color kRed, Color kOrange, Color kCardColor, bool isDark, Color kGrayText) {
    return _buildCard(
      title: 'Fiyat Uyumluluğu',
      icon: Icons.price_check,
      kPrimaryBlue: kPrimaryBlue,
      kTextColor: isDark ? Colors.white : const Color(0xFF333333),
      kCardColor: kCardColor,
      isDark: isDark,
      child: Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 20,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final products = ['A', 'B', 'C', 'D'];
                        if (value.toInt() >= 0 && value.toInt() < products.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text('Ürün ${products[value.toInt()]}', style: TextStyle(fontSize: 10, color: kGrayText)),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                barGroups: priceData.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> data = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data['correct'] + data['incorrect'],
                        width: 20,
                        color: Colors.transparent,
                        rodStackItems: [
                          BarChartRodStackItem(0, data['correct'], kGreen),
                          BarChartRodStackItem(data['correct'], data['correct'] + data['incorrect'], kRed),
                        ],
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendDot(kGreen, 'Doğru Fiyat', kGrayText),
              const SizedBox(width: 16),
              _buildLegendDot(kRed, 'Yanlış Fiyat', kGrayText),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kOrange.withOpacity(0.1),
              border: Border.all(color: kOrange.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: kGrayText, fontSize: 13),
                      children: [
                        TextSpan(text: '9 ürün', style: TextStyle(color: kRed, fontWeight: FontWeight.bold)),
                        const TextSpan(text: ' satılması gereken fiyattan farklı bir fiyata satılıyor.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- 8. VOID ANALYSIS ---
  Widget _buildVoidAnalysis(List<Map<String, dynamic>> voidAnalysis, Color kTextColor, Color kPrimaryBlue, Color kRed, Color kCardColor, bool isDark, Color kGrayText) {
    return _buildCard(
      title: 'Void Analysis (Boşluk & Stok)',
      icon: Icons.error_outline,
      kTextColor: kTextColor,
      kPrimaryBlue: kPrimaryBlue,
      kCardColor: kCardColor,
      isDark: isDark,
      child: Column(
        children: voidAnalysis.map((item) {
          bool isLow = item['stockLevel'] == 'low';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLow ? kRed.withOpacity(0.05) : kPrimaryBlue.withOpacity(0.05),
              border: Border.all(color: isLow ? kRed.withOpacity(0.2) : kPrimaryBlue.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(item['type'], style: TextStyle(color: kTextColor, fontSize: 13, fontWeight: FontWeight.w500)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isLow ? kRed.withOpacity(0.2) : kPrimaryBlue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isLow ? 'Low Stock' : 'High Stock',
                              style: TextStyle(color: isLow ? Colors.red.shade800 : Colors.blue.shade800, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLow ? 'Ürün stoğu yetersiz - Sipariş gerekli' : 'Fazla stok tespit edildi',
                        style: TextStyle(color: kGrayText, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLow ? kRed : kPrimaryBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${item['count']}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- GENEL KART TASARIMI ---
  Widget _buildCard({
    required String title,
    IconData? icon,
    required Widget child,
    Color kPrimaryBlue = const Color(0xFF007AFF),
    Color kTextColor = const Color(0xFF333333),
    required Color kCardColor, // DÜZELTME: Kart Rengi Parametresi
    required bool isDark, // DÜZELTME: Dark mode bilgisi
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor, // DÜZELTME: Dinamik renk
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Row(
              children: [
                Icon(icon, size: 20, color: kPrimaryBlue),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(color: kTextColor, fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
          ] else ...[
            Text(title, style: TextStyle(color: kTextColor, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String text, Color kGrayText) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: kGrayText, fontSize: 12)),
      ],
    );
  }
}