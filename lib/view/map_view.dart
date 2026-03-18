import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_vision_mobile/view_model/map_view_model.dart';

class MapScreen extends ConsumerWidget {
  final LatLng? targetLocation;

  const MapScreen({super.key, this.targetLocation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(mapViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Navigasyon')),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: viewModel.targetLocation ?? const LatLng(38.4237, 27.1428),
              zoom: 14.5,
            ),
            markers: viewModel.markers,
            polylines: viewModel.polylines,
            onMapCreated: viewModel.onMapCreated,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
          ),

          if (viewModel.targetLocation != null)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        viewModel.createRoute();
                      },
                      label: const Text("Yol Tarifi Al"),
                      icon: const Icon(Icons.directions),
                      backgroundColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
        ],
      ),
    );
  }
}