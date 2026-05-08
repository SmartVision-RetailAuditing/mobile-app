// view/product_correction_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/audit_dto.dart';
import '../model/audit_product_dto.dart';
import '../model/catalog_product.dart';
import '../view_model/product_correction_view_model.dart';

class ProductCorrectionScreen extends ConsumerStatefulWidget {
  final AuditDto initialAudit;
  const ProductCorrectionScreen({super.key, required this.initialAudit});

  @override
  ConsumerState<ProductCorrectionScreen> createState() => _ProductCorrectionScreenState();
}

class _ProductCorrectionScreenState extends ConsumerState<ProductCorrectionScreen> {
  double? imgWidth;
  double? imgHeight;
  List<CatalogProduct> catalog = [];

  @override
  void initState() {
    super.initState();
    _loadImageResolution();
    _loadCatalog();
  }

  // --- 1. JSON KATALOĞUNU YÜKLE VE ALFABETİK SIRALA ---
  Future<void> _loadCatalog() async {
    try {
      final String response = await rootBundle.loadString('assets/data/product_catalog_sut.json');
      final Map<String, dynamic> data = jsonDecode(response);

      List<CatalogProduct> loadedCatalog = [];
      data.forEach((key, value) {
        loadedCatalog.add(CatalogProduct.fromJson(value));
      });

      // --- KRİTİK EKLENTİ: LİSTEYİ A'DAN Z'YE SIRALAMA ---
      // displayTitle (Yani "Marka - Ürün Adı") değerine göre sıralıyoruz.
      // toLowerCase() ekliyoruz ki küçük/büyük harf sıralamayı bozmasın.
      loadedCatalog.sort((a, b) => a.displayTitle.toLowerCase().compareTo(b.displayTitle.toLowerCase()));

      if (mounted) {
        setState(() {
          catalog = loadedCatalog;
        });
      }
    } catch (e) {
      debugPrint("🚨 Katalog yüklenirken hata: $e");
    }
  }

  // --- 2. RESMİN GERÇEK PİKSEL ÇÖZÜNÜRLÜĞÜNÜ BUL ---
  void _loadImageResolution() {
    if (widget.initialAudit.postImageUrl == null) return;

    final imageProvider = NetworkImage(widget.initialAudit.postImageUrl!);
    imageProvider.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool synchronousCall) {
        if (mounted) {
          setState(() {
            imgWidth = info.image.width.toDouble();
            imgHeight = info.image.height.toDouble();
          });
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(correctionProvider(widget.initialAudit));
    final viewModel = ref.read(correctionProvider(widget.initialAudit).notifier);

    final selectedProduct = state.selectedProductId == null
        ? null
        : state.audit.products.firstWhere(
            (p) => p.id == state.selectedProductId,
        orElse: () => state.audit.products.first
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Ürünleri İncele", style: TextStyle(color: Colors.white)),
        actions: [
          if (state.isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
              ),
            )
          else
            TextButton(
              onPressed: () async {
                final success = await viewModel.submitChanges();
                if (success && context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text("BİTİR", style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold)),
            )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              maxScale: 5.0,
              minScale: 1.0,
              child: Center(
                child: (imgWidth == null || imgHeight == null)
                    ? const CircularProgressIndicator(color: Colors.white)
                    : FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: imgWidth,
                    height: imgHeight,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            state.audit.postImageUrl!,
                            fit: BoxFit.fill,
                          ),
                        ),
                        ...state.audit.products.map((product) {
                          final isSelected = product.id == state.selectedProductId;

                          return Positioned(
                            left: product.boundingBoxX,
                            top: product.boundingBoxY,
                            width: product.boundingBoxWidth,
                            height: product.boundingBoxHeight,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                debugPrint("✅ TIKLANDI: ${product.brandName} - ${product.productName}");
                                viewModel.selectProduct(product.id);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.yellow.withOpacity(0.3) : Colors.transparent,
                                  border: isSelected ? Border.all(color: Colors.yellow, width: 4) : null,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // ViewModel'i metoda gönderiyoruz ki dropdown'dan seçim yapınca tetikleyebilelim
          _buildBottomDetailBar(selectedProduct, viewModel),
        ],
      ),
    );
  }

  Widget _buildBottomDetailBar(AuditProductDto? product, CorrectionViewModel vm) {
    return Container(
      width: double.infinity,
      height: 280, // Dropdown açıldığında ekranı itmemesi için sabit yükseklik
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: product == null
          ? const Center(
        child: Text(
          "Bilgisini görmek veya düzenlemek istediğiniz\nürünün üzerine dokunun.",
          style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
      )
          : SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "YAPAY ZEKA TESPİTİ (ID: ${product.id})",
                style: const TextStyle(color: Colors.greenAccent, fontSize: 12, letterSpacing: 1.2, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 8),
            Text(
              product.brandName,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              product.productName,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const Divider(color: Colors.white24, height: 24),

            const Text("HATALI MI? DOĞRUSUNU SEÇİN:", style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 8),

            // --- DROPDOWN (AÇILIR LİSTE) ---
            catalog.isEmpty
                ? const LinearProgressIndicator(color: Colors.yellow)
                : DropdownButtonFormField<CatalogProduct>(
              key: ValueKey(product.id), // KRİTİK EKLENTİ: Her yeni üründe dropdown sıfırlanır!
              value: null,
              isExpanded: true,
              dropdownColor: Colors.grey[900],
              icon: const Icon(Icons.edit, color: Colors.yellow, size: 20),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white10,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              hint: const Text("Katalogdan yeni ürün seçin...", style: TextStyle(color: Colors.white54)),
              items: catalog.map((catProduct) {
                return DropdownMenuItem<CatalogProduct>(
                  value: catProduct,
                  child: Text(catProduct.displayTitle, style: const TextStyle(color: Colors.white, fontSize: 14)),
                );
              }).toList(),
              onChanged: (CatalogProduct? newValue) {
                if (newValue != null) {
                  vm.updateProductFromCatalog(product.id, newValue);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}