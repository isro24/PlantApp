import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _ctrl = Completer();
  Marker? _pickedMarker;
  String? _pickedAddress;
  String? _currentAddress;
  CameraPosition? _initialCamera;
  Position? _currentPosition;

  @override initState(){
    super.initState();
    _setupLocation();
  }

  Future<void> _setupLocation() async {
    try{
      final pos = await getPermissions();
      _currentPosition = pos;
      _initialCamera = CameraPosition(
        target: LatLng(pos.latitude, pos.longitude),
        zoom: 16
      );

      final placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude, 
        _currentPosition!.longitude
      );

      final p = placemarks.first;
      _currentAddress = "${p.name}, ${p.locality},${p.country}";

      setState(() {});
    } catch(e) {
      // Jika gagal (denied, service off), fallback ke view global
      _initialCamera = const CameraPosition(target: LatLng(0, 0), zoom: 2);
      setState(() {});
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<Position> getPermissions() async {
    // 1. Cek Service GPS
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw "Location service belum aktif";
    }

    // 2. Cek & minta permission
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        throw "Izin lokasi ditolak";
      }
    }
    if (perm == LocationPermission.deniedForever) {
      throw "Izin lokasi ditolak permanen";
    }

    // 3. Semua OK, ambil posisi
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _onTap(LatLng latlng) async {
    final placemarks = await placemarkFromCoordinates(
      latlng.latitude, 
      latlng.longitude
    );

    final p = placemarks.first;
    setState(() {
      _pickedMarker = Marker(
        markerId: const MarkerId("picked"),
        position: latlng,
        infoWindow: InfoWindow(
          title: p.name?.isNotEmpty == true ? p.name : "Lokasi Dipilhh",
          snippet: '${p.street}, ${p.locality}',
        ),
      );
    });
    final ctrl = await _ctrl.future;
    await ctrl.animateCamera(CameraUpdate.newLatLngZoom(latlng, 16));

    setState(() {
      _pickedAddress = 
        '${p.locality}, ${p.country}';
    });
  }

  void _confirmSelection(){
    showDialog(
      context: context, 
      builder: 
        (_) => AlertDialog(
          title: const Text("Konfirmasi alamat"),
          content: Text(_pickedAddress ?? ''),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Batal')
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, _pickedAddress);
              }, 
              child: const Text('Pilih')
            )
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pilih Alamat"),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _initialCamera!,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              mapType: MapType.normal,
              compassEnabled: true,
              tiltGesturesEnabled: false,
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              rotateGesturesEnabled: true,
              trafficEnabled: true,
              buildingsEnabled: true,
              indoorViewEnabled: true,
              onMapCreated: (GoogleMapController ctrl){
                _ctrl.complete(ctrl);
              },

              markers: _pickedMarker != null ? {_pickedMarker!} : {},
              onTap: _onTap,
            ),
            Positioned(
              top: 70,
              left: 56,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ]
                ),
                child: Text(_currentAddress ?? 'Kosong'),
              )
            ),
            if (_pickedAddress != null)
              Positioned(
                bottom: 120,
                left: 16,
                right: 16,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _pickedAddress!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                ),
              )
          ],
        )
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          const SizedBox(height: 8),
          if (_pickedAddress != null)
            FloatingActionButton.extended(
              heroTag: 'confirm',
              onPressed: _confirmSelection,
              label: const Text('Pilih Alamat'),
            ),
          const SizedBox(height: 8),
          if (_pickedAddress != null)
          // clear
            FloatingActionButton.extended(
              heroTag: 'clear',
              label: const Text('Hapus Alamat'),
              onPressed: () {
                setState(() {
                  _pickedAddress = null;
                  _pickedMarker = null;
                });
              },
            ),
        ]
      ),
    );
  }
}