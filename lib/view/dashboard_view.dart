import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_vision_mobile/providers.dart';
import 'package:smart_vision_mobile/tools/AppColors.dart';
import '../model/audit_dto.dart';
import '../model/audit_issue_dto.dart';
import '../view_model/dashboard_view_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(dashboardViewModelProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color kBgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color kTextColor = Theme.of(context).textTheme.bodyMedium!.color!;
    final Color kCardColor = Theme.of(context).cardColor;
    final Color kPrimaryBlue = AppColors.colorPrimaryBlue;
    final Color kGreen = AppColors.colorGreen;
    final Color kOrange = AppColors.colorOrange;
    final Color kRed = AppColors.colorRed;
    final Color kGrayText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    if (viewModel.isLoading) {
      return Scaffold(
        backgroundColor: kBgColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.errorMessage != null) {
      return Scaffold(
        backgroundColor: kBgColor,
        body: Center(
          child: Text(
            'Veriler yüklenirken hata oluştu:\n${viewModel.errorMessage}',
            textAlign: TextAlign.center,
            style: TextStyle(color: kRed),
          ),
        ),
      );
    }

    if (viewModel.recentAudits.isEmpty || viewModel.currentAudit == null) {
      return Scaffold(
        backgroundColor: kBgColor,
        body: Center(
          child: Text('Henüz tamamlanmış bir denetim bulunmuyor.', style: TextStyle(color: kGrayText)),
        ),
      );
    }

    final recentAudits = viewModel.recentAudits;
    final currentAudit = viewModel.currentAudit!;

    final shelfShareData = viewModel.getShelfShareData(currentAudit);
    final priceData = viewModel.getPriceCompliance(currentAudit);
    final voidAnalysis = viewModel.getVoidAnalysis(currentAudit);
    final nonCompliantItems = currentAudit.issues;

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
                  _buildSelectedVisitSection(context, ref, viewModel, recentAudits, currentAudit.id, kPrimaryBlue, kBgColor, kTextColor, kCardColor, isDark),
                  const SizedBox(height: 16),
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
                        Text(currentAudit.storeName, style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (shelfShareData.isNotEmpty) ...[
                    _buildShelfShareChart(shelfShareData, kPrimaryBlue, kTextColor, kCardColor, isDark, kGrayText),
                    const SizedBox(height: 16),
                  ],
                  _buildAvailabilityGauge(currentAudit, kPrimaryBlue, kTextColor, kCardColor, isDark, kGrayText),
                  const SizedBox(height: 16),
                  _buildPlanogramCompliance(nonCompliantItems, currentAudit.complianceScore, kTextColor, kBgColor, kGreen, kRed, kCardColor, isDark, kGrayText),
                  const SizedBox(height: 16),
                  if (priceData.isNotEmpty) ...[
                    _buildPriceComplianceChart(priceData, kPrimaryBlue, kGreen, kRed, kOrange, kCardColor, isDark, kGrayText),
                    const SizedBox(height: 16),
                  ],
                  if (voidAnalysis.isNotEmpty) ...[
                    _buildVoidAnalysis(voidAnalysis, kTextColor, kPrimaryBlue, kRed, kCardColor, isDark, kGrayText),
                    const SizedBox(height: 30),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        color: kCardColor,
        boxShadow: [
          BoxShadow(color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Text('Dashboard', style: TextStyle(color: kTextColor, fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSelectedVisitSection(BuildContext context, WidgetRef ref, DashboardViewModel viewModel, List<AuditDto> recentVisits, int selectedVisitId, Color kPrimaryBlue, Color kBgColor, Color kTextColor, Color kCardColor, bool isDark) {
    final selectedVisit = recentVisits.firstWhere((v) => v.id == selectedVisitId, orElse: () => recentVisits.first);
    final score = selectedVisit.complianceScore.toInt();
    final dateStr = "${selectedVisit.captureDate.day}/${selectedVisit.captureDate.month}/${selectedVisit.captureDate.year}";

    return _buildCard(
      title: 'İncelenen Ziyaret',
      icon: Icons.storefront,
      kPrimaryBlue: kPrimaryBlue,
      kTextColor: kTextColor,
      kCardColor: kCardColor,
      isDark: isDark,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showVisitsBottomSheet(context, ref, selectedVisitId, kPrimaryBlue, kBgColor, kTextColor, kCardColor, isDark),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kPrimaryBlue,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: kPrimaryBlue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(selectedVisit.storeName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: Colors.white70),
                            const SizedBox(width: 6),
                            Text(dateStr, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: Text('$score%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text("Farklı bir ziyareti incelemek için yukarıdaki karta tıklayın.", style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  // --- KRİTİK DEĞİŞİKLİK: BOTTOM SHEET ARTIK REACTIVE ---
  void _showVisitsBottomSheet(
      BuildContext context,
      WidgetRef ref,
      int selectedId,
      Color kPrimaryBlue,
      Color kBgColor,
      Color kTextColor,
      Color kCardColor,
      bool isDark) {

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final vm = ref.watch(dashboardViewModelProvider);
            final visits = vm.recentAudits;

            return DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.85,
              builder: (_, scrollController) {
                // YENİ YÖNTEM: Listener'ı controller yerine NotificationListener ile sarmalıyoruz
                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    // Listenin sonuna 100 piksel kala yeni veriyi tetikle
                    if (!vm.isLoadingMore &&
                        scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100) {
                      vm.loadDashboardData();
                      return true; // Bildirimi durdur
                    }
                    return false;
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Drag Handle (Sürükleme Çubuğu)
                        Container(
                          width: 40, height: 5,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10)),
                        ),
                        Text("Tüm Ziyaretler", style: TextStyle(color: kTextColor, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),

                        Expanded(
                          child: ListView.builder(
                            controller: scrollController, // Sheet'ten gelen controller'ı kullanmak zorunlu
                            // ÖNEMLİ: Liste az olsa bile kaydırma hareketini algılaması için bu physics şart
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: visits.length + (vm.isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == visits.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }

                              final visit = visits[index];
                              final isSelected = visit.id == selectedId;
                              final score = visit.complianceScore.toInt();
                              final dateStr = "${visit.captureDate.day}/${visit.captureDate.month}/${visit.captureDate.year}";

                              Color badgeColorBg = score >= 85 ? Colors.green.shade100 : (score >= 70 ? Colors.orange.shade100 : Colors.red.shade100);
                              Color badgeColorText = score >= 85 ? Colors.green.shade700 : (score >= 70 ? Colors.orange.shade700 : Colors.red.shade700);

                              return GestureDetector(
                                onTap: () {
                                  ref.read(dashboardViewModelProvider).selectVisit(visit.id);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected ? kPrimaryBlue.withOpacity(0.1) : kBgColor,
                                    border: Border.all(color: isSelected ? kPrimaryBlue : (isDark ? Colors.grey.shade800 : Colors.grey.shade200)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              visit.storeName,
                                              style: TextStyle(
                                                color: isSelected ? kPrimaryBlue : kTextColor,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(color: badgeColorBg, borderRadius: BorderRadius.circular(20)),
                                        child: Text('$score%', style: TextStyle(color: badgeColorText, fontWeight: FontWeight.bold, fontSize: 13)),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // --- DİĞER CHART VE CARD WIDGET'LARI AYNEN KALIYOR ---
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
                  return PieChartSectionData(color: item['color'], value: item['value'], title: '${item['value'].toInt()}%', radius: 60, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white));
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: data.map((item) {
              return Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: item['color'], shape: BoxShape.circle)), const SizedBox(width: 6), Text(item['name'], style: TextStyle(color: kGrayText, fontSize: 12))]);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityGauge(AuditDto currentAudit, Color kPrimaryBlue, Color kTextColor, Color kCardColor, bool isDark, Color kGrayText) {
    double percentage = currentAudit.complianceScore / 100.0;
    return _buildCard(
      title: 'Bulunabilirlik Oranı',
      icon: Icons.inventory_2_outlined,
      kPrimaryBlue: kPrimaryBlue,
      kTextColor: kTextColor,
      kCardColor: kCardColor,
      isDark: isDark,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(width: 150, height: 150, child: CircularProgressIndicator(value: 1.0, strokeWidth: 12, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200)),
                SizedBox(width: 150, height: 150, child: CircularProgressIndicator(value: percentage, strokeWidth: 12, color: kPrimaryBlue, strokeCap: StrokeCap.round)),
                Column(mainAxisSize: MainAxisSize.min, children: [Text('${(percentage * 100).toInt()}%', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: kTextColor)), Text('Bulunabilir', style: TextStyle(fontSize: 12, color: Colors.grey.shade500))]),
              ],
            ),
            const SizedBox(height: 16),
            Text(percentage >= 0.8 ? 'Analiz tamamlandı. Ürünler rafta yeterli seviyede.' : 'Analiz tamamlandı. Raf bulunabilirliği düşük seviyede!', style: TextStyle(color: kGrayText, fontSize: 13), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanogramCompliance(List<AuditIssueDto> nonCompliantItems, double score, Color kTextColor, Color kBgColor, Color kGreen, Color kRed, Color kCardColor, bool isDark, Color kGrayText) {
    return _buildCard(
      title: 'Planogram Compliance',
      icon: Icons.bar_chart,
      kTextColor: kTextColor,
      kCardColor: kCardColor,
      isDark: isDark,
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Genel Uyumluluk', style: TextStyle(color: kGrayText, fontSize: 13)), Text('${score.toInt()}%', style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: score / 100.0, minHeight: 10, backgroundColor: kBgColor, color: score >= 80 ? kGreen : (score >= 60 ? Colors.orange : kRed))),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerLeft, child: Text('Anlaşmaya Uymayan Maddeler:', style: TextStyle(color: kGrayText, fontSize: 13))),
          const SizedBox(height: 8),
          if (nonCompliantItems.isEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text("Hata tespit edilmedi. Harika!", style: TextStyle(color: kGreen))) else ...nonCompliantItems.map((item) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: item.severity == "CRITICAL" ? kRed.withOpacity(0.05) : Colors.orange.withOpacity(0.05), border: Border.all(color: item.severity == "CRITICAL" ? kRed.withOpacity(0.2) : Colors.orange.withOpacity(0.2)), borderRadius: BorderRadius.circular(12)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.error_outline, color: item.severity == "CRITICAL" ? kRed : Colors.orange, size: 18), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.issueType, style: TextStyle(color: kTextColor, fontSize: 13, fontWeight: FontWeight.w600)), const SizedBox(height: 2), Text(item.description, style: TextStyle(color: item.severity == "CRITICAL" ? kRed : Colors.orange.shade700, fontSize: 11))]))]))),
        ],
      ),
    );
  }

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
                alignment: BarChartAlignment.spaceAround, maxY: 20, barTouchData: BarTouchData(enabled: false), titlesData: FlTitlesData(show: true, bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (double value, TitleMeta meta) { if (value.toInt() >= 0 && value.toInt() < priceData.length) { return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(priceData[value.toInt()]['product'].toString().substring(0, 3), style: TextStyle(fontSize: 10, color: kGrayText))); } return const SizedBox(); })), leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))), gridData: FlGridData(show: true, drawVerticalLine: false), borderData: FlBorderData(show: false),
                barGroups: priceData.asMap().entries.map((entry) { int index = entry.key; Map<String, dynamic> data = entry.value; return BarChartGroupData(x: index, barRods: [BarChartRodData(toY: data['correct'] + data['incorrect'], width: 20, color: Colors.transparent, rodStackItems: [BarChartRodStackItem(0, data['correct'], kGreen), BarChartRodStackItem(data['correct'], data['correct'] + data['incorrect'], kRed)], borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)))]); }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildLegendDot(kGreen, 'Doğru Fiyat', kGrayText), const SizedBox(width: 16), _buildLegendDot(kRed, 'Yanlış Fiyat / Okunamadı', kGrayText)]),
        ],
      ),
    );
  }

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
          return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isLow ? kRed.withOpacity(0.05) : kPrimaryBlue.withOpacity(0.05), border: Border.all(color: isLow ? kRed.withOpacity(0.2) : kPrimaryBlue.withOpacity(0.2)), borderRadius: BorderRadius.circular(12)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text(item['type'], style: TextStyle(color: kTextColor, fontSize: 13, fontWeight: FontWeight.w500)), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: isLow ? kRed.withOpacity(0.2) : kPrimaryBlue.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: Text(isLow ? 'Uyarı' : 'High Stock', style: TextStyle(color: isLow ? Colors.red.shade800 : Colors.blue.shade800, fontSize: 10, fontWeight: FontWeight.bold)))],), const SizedBox(height: 4), Text(isLow ? 'Tespit edilen hata sayısı' : 'Fazla stok tespit edildi', style: TextStyle(color: kGrayText, fontSize: 11))])), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: isLow ? kRed : kPrimaryBlue, borderRadius: BorderRadius.circular(12)), child: Text('${item['count']}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)))],));
        }).toList(),
      ),
    );
  }

  Widget _buildCard({required String title, IconData? icon, required Widget child, Color kPrimaryBlue = const Color(0xFF007AFF), Color kTextColor = const Color(0xFF333333), required Color kCardColor, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: kCardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (icon != null) ...[Row(children: [Icon(icon, size: 20, color: kPrimaryBlue), const SizedBox(width: 8), Text(title, style: TextStyle(color: kTextColor, fontSize: 15, fontWeight: FontWeight.bold))]), const SizedBox(height: 16)] else ...[Text(title, style: TextStyle(color: kTextColor, fontSize: 15, fontWeight: FontWeight.bold)), const SizedBox(height: 16)], child]),
    );
  }

  Widget _buildLegendDot(Color color, String text, Color kGrayText) {
    return Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 6), Text(text, style: TextStyle(color: kGrayText, fontSize: 12))]);
  }
}