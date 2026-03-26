import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

final mapViewModelProvider = ChangeNotifierProvider.autoDispose<MapViewModel>((ref) {
  return MapViewModel();
});

class MapViewModel extends ChangeNotifier {
  final Completer<GoogleMapController> controller = Completer<GoogleMapController>();

  LatLng? targetLocation;

  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};

  MapViewModel();

  Future<void> setTargetLocation(LatLng location) async {
    targetLocation = location;

    markers.clear();
    polylines.clear();

    markers.add(
      Marker(
        markerId: const MarkerId('target_task'),
        position: targetLocation!,
        infoWindow: const InfoWindow(title: 'Görev Adresi'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    if (controller.isCompleted) {
      try {
        final GoogleMapController mapController = await controller.future;
        mapController.animateCamera(CameraUpdate.newLatLngZoom(targetLocation!, 15));
      } catch (e) {
        debugPrint("Kamera taşıma hatası: $e");
      }
    }

    notifyListeners();
  }

  void onMapCreated(GoogleMapController mapController) {
    if (!controller.isCompleted) {
      controller.complete(mapController);

      if (targetLocation != null) {
        mapController.animateCamera(CameraUpdate.newLatLngZoom(targetLocation!, 15));
      }
    }
  }

  // DEĞİŞİKLİK BURADA: Artık BuildContext alıyor ki diyalog gösterebilsin
  Future<void> createRoute(BuildContext context) async {
    if (targetLocation == null) {
      debugPrint("Hedef konum yok, rota çizilemiyor.");
      return;
    }

    // 1. KONTROL: GPS (Konum Servisi) açık mı?
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        _showSettingsDialog(
          context: context,
          title: "Konum Servisleri Kapalı",
          message: "Yol tarifi alabilmek için lütfen cihazınızın konum (GPS) servisini açın.",
          onConfirm: () => Geolocator.openLocationSettings(),
        );
      }
      return; // Servis kapalıysa devam etme
    }

    // 2. KONTROL: Uygulamaya konum izni verilmiş mi?
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Rota çizmek için konum iznine ihtiyacımız var."), backgroundColor: Colors.orange),
          );
        }
        return;
      }
    }

    // 3. KONTROL: İzin kalıcı olarak reddedilmişse (Kullanıcı "Bir Daha Sorma" demişse)
    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        _showSettingsDialog(
          context: context,
          title: "Konum İzni Gerekli",
          message: "Konum izni kalıcı olarak reddedilmiş. Lütfen ayarlara giderek uygulamaya konum izni verin.",
          onConfirm: () => Geolocator.openAppSettings(),
        );
      }
      return;
    }

    // --- HER ŞEY YOLUNDAYSA ROTA ÇİZİMİNE BAŞLA ---

    Position userPosition = await Geolocator.getCurrentPosition();
    LatLng userLocation = LatLng(userPosition.latitude, userPosition.longitude);

    markers.add(
      Marker(
        markerId: const MarkerId('my_location'),
        position: userLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Konumum'),
      ),
    );

    final String osrmUrl =
        "http://router.project-osrm.org/route/v1/driving/"
        "${userLocation.longitude},${userLocation.latitude};"
        "${targetLocation!.longitude},${targetLocation!.latitude}"
        "?overview=full&geometries=polyline";

    try {
      final response = await http.get(Uri.parse(osrmUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'].isNotEmpty) {
          String encodedPolyline = data['routes'][0]['geometry'];
          List<PointLatLng> decodedPoints = PolylinePoints.decodePolyline(encodedPolyline);

          List<LatLng> routeCoords = decodedPoints
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();

          Polyline routeLine = Polyline(
            polylineId: const PolylineId("osrm_route"),
            color: Colors.blue,
            points: routeCoords,
            width: 6,
          );

          polylines.add(routeLine);
          _fitBounds(userLocation, targetLocation!);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Rota hatası: $e");
    }
  }

  // YENİ EKLENEN YARDIMCI DİYALOG FONKSİYONU
  void _showSettingsDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.location_off, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 18))),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("İptal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                onConfirm(); // Ayarları açan Geolocator fonksiyonunu tetikler
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text("Ayarlara Git"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fitBounds(LatLng origin, LatLng dest) async {
    final GoogleMapController mapController = await controller.future;

    double minLat = origin.latitude < dest.latitude ? origin.latitude : dest.latitude;
    double maxLat = origin.latitude > dest.latitude ? origin.latitude : dest.latitude;
    double minLong = origin.longitude < dest.longitude ? origin.longitude : dest.longitude;
    double maxLong = origin.longitude > dest.longitude ? origin.longitude : dest.longitude;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLong),
      northeast: LatLng(maxLat, maxLong),
    );
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }
}