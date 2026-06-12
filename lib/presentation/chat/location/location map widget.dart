// lib/presentation/chat/location/location_map_widget.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationMapWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double zoom;
  final double? height;
  final bool showMarker;
  final String? markerTitle;
  final bool interactive;

  const LocationMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 14,
    this.height,
    this.showMarker = true,
    this.markerTitle,
    this.interactive = false,
  });

  @override
  State<LocationMapWidget> createState() => _LocationMapWidgetState();
}

class _LocationMapWidgetState extends State<LocationMapWidget> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    if (widget.showMarker) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: LatLng(widget.latitude, widget.longitude),
          infoWindow: widget.markerTitle != null
              ? InfoWindow(title: widget.markerTitle)
              : null,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height ?? 200,
      width: double.infinity,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.latitude, widget.longitude),
          zoom: widget.zoom,
        ),
        markers: _markers,
        onMapCreated: (controller) => _mapController = controller,
        zoomControlsEnabled: widget.interactive,
        scrollGesturesEnabled: widget.interactive,
        zoomGesturesEnabled: widget.interactive,
        myLocationEnabled: widget.interactive,
      ),
    );
  }
}
