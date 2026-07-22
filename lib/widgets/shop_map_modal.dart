// lib/screens/shops/shop_map_modal.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../services/map_service.dart';
import '../../theme/app_colors.dart';

class ShopMapModal extends StatefulWidget {
  final double shopLat;
  final double shopLng;

  const ShopMapModal({
    super.key,
    required this.shopLat,
    required this.shopLng,
  });

  @override
  State<ShopMapModal> createState() => _ShopMapModalState();
}

class _ShopMapModalState extends State<ShopMapModal> {
  final MapController _mapController = MapController();

  Timer? _timer;

  bool mapReady = false;
  bool followUser = true;

  LatLng? userLocation;
  List<LatLng> routePoints = [];

  bool loading = true;

  double _heading = 0;
  double speed = 0;
  double remainingDistance = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  // ================= INIT =================
  Future<void> _init() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(() => loading = false);
        return;
      }

      LocationPermission perm = await Geolocator.checkPermission();

      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final user = LatLng(pos.latitude, pos.longitude);
      final shop = LatLng(widget.shopLat, widget.shopLng);

      userLocation = user;

      remainingDistance = Geolocator.distanceBetween(
        user.latitude,
        user.longitude,
        shop.latitude,
        shop.longitude,
      );

      final route = await MapService().getRoute(user, shop);

      setState(() {
        routePoints = route.isNotEmpty ? route : [user, shop];
        loading = false;
      });

      Future.delayed(const Duration(milliseconds: 400), () {
        if (mapReady && userLocation != null) {
          _mapController.move(userLocation!, 16);
        }
      });

      _startTracking();
    } catch (e) {
      debugPrint("INIT ERROR: $e");
      setState(() => loading = false);
    }
  }

  // ================= LIVE TRACKING =================
  void _startTracking() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      final newUser = LatLng(pos.latitude, pos.longitude);
      final shop = LatLng(widget.shopLat, widget.shopLng);

      _heading =
          (pos.heading.isFinite && pos.heading >= 0) ? pos.heading : 0;

      speed = pos.speed;

      remainingDistance = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        shop.latitude,
        shop.longitude,
      );

      setState(() {
        userLocation = newUser;
      });

      if (mapReady && followUser) {
        _mapController.move(
          newUser,
          _mapController.camera.zoom,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final shop = LatLng(widget.shopLat, widget.shopLng);

    if (loading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.primary(context),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade100,
      child: Stack(
        children: [
          // ================= MAP =================
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: userLocation ?? shop,
              initialZoom: 16,
              onMapReady: () {
                mapReady = true;
              },
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture) {
                  followUser = false;
                  setState(() {});
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: kIsWeb
                    ? 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: kIsWeb ? const ['a', 'b', 'c', 'd'] : const [],
                userAgentPackageName: 'com.example.mangochi_marketplace',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 5,
                    color: AppColors.primary(context),
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  if (userLocation != null)
                    Marker(
                      point: userLocation!,
                      width: 60,
                      height: 60,
                      child: Transform.rotate(
                        angle: _heading * (pi / 180),
                        child: Icon(
                          Icons.navigation,
                          color: AppColors.primary(context),
                          size: 32,
                        ),
                      ),
                    ),
                  Marker(
                    point: shop,
                    width: 60,
                    height: 60,
                    child: const Icon(
                      Icons.storefront,
                      color: Colors.green,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ================= FLOATING PILL INFO =================
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            top: followUser ? 16 : 10,
            left: 16,
            right: 16,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: followUser
                    ? MediaQuery.of(context).size.width > 700
                        ? 420
                        : double.infinity
                    : 140,
                padding: followUser
                    ? const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      )
                    : const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: followUser
                    ? _expandedCard()
                    : _collapsedCard(),
              ),
            ),
          ),

          // ================= RECENTER BUTTON =================
          Positioned(
            bottom: 110,
            right: 18,
            child: FloatingActionButton(
              heroTag: "follow",
              backgroundColor: AppColors.primary(context),
              child: const Icon(Icons.my_location),
              onPressed: () {
                followUser = true;

                if (userLocation != null && mapReady) {
                  _mapController.move(userLocation!, 16);
                }

                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= EXPANDED CARD =================
  Widget _expandedCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // SPEED
        Row(
          children: [
            Icon(Icons.speed,
                size: 18, color: AppColors.primary(context)),
            const SizedBox(width: 8),
            Text(
              "${(speed * 3.6).toStringAsFixed(1)} km/h",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),

        // DISTANCE
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.leafGreen.withOpacity(0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            "${(remainingDistance / 1000).toStringAsFixed(2)} km",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.leafGreen,
            ),
          ),
        ),
      ],
    );
  }

  // ================= COLLAPSED CARD =================
  Widget _collapsedCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.navigation,
            size: 18, color: AppColors.primary(context)),
        const SizedBox(width: 6),
        Text(
          "${(remainingDistance / 1000).toStringAsFixed(1)} km",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}