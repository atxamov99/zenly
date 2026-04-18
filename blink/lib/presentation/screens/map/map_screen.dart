import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../domain/entities/friend_location_entity.dart';
import '../../providers/location_provider.dart';
import '../../providers/socket_provider.dart';
import '../../widgets/glass/glass_fab.dart';
import 'widgets/friend_location_sheet.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  static const _initialCenter = LatLng(41.3111, 69.2797); // Tashkent

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final locationService = ref.read(locationServiceProvider);
    locationService.initForegroundTask();

    final granted = await locationService.requestPermissions();
    if (!granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Joylashuv ruxsati kerak')),
      );
      return;
    }

    final socket = ref.read(socketServiceProvider);
    try {
      await socket.connect();
    } catch (e) {
      debugPrint('Socket connect error: $e');
    }

    await locationService.startService();

    try {
      final position = await Geolocator.getCurrentPosition();
      final me = LatLng(position.latitude, position.longitude);
      ref.read(ownLocationProvider.notifier).state = me;
      _mapController.move(me, 15);
    } catch (e) {
      debugPrint('GetCurrentPosition error: $e');
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _showFriendSheet(FriendLocationEntity friend) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => FriendLocationSheet(friend: friend),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ownLocation = ref.watch(ownLocationProvider);
    final friendsAsync = ref.watch(friendsLocationProvider);

    final markers = <Marker>[];
    if (ownLocation != null) {
      markers.add(
        Marker(
          point: ownLocation,
          width: 60,
          height: 60,
          child: const _OwnMarker(),
        ),
      );
    }
    friendsAsync.whenData((friends) {
      for (final friend in friends.values) {
        markers.add(
          Marker(
            point: LatLng(friend.lat, friend.lng),
            width: 64,
            height: 64,
            child: GestureDetector(
              onTap: () => _showFriendSheet(friend),
              child: _FriendMarker(friend: friend),
            ),
          ),
        );
      }
    });

    return Scaffold(
      body: WithForegroundTask(
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: _initialCenter,
                initialZoom: 13,
                minZoom: 3,
                maxZoom: 18,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.blink.app.blink',
                ),
                MarkerLayer(markers: markers),
              ],
            ),
            Positioned(
              right: 16,
              bottom: 32,
              child: GlassFab(
                icon: Icons.my_location,
                onPressed: () {
                  if (ownLocation != null) {
                    _mapController.move(ownLocation, 16);
                  }
                },
              ),
            ),
            Positioned(
              right: 16,
              top: 48,
              child: GlassFab(
                icon: Icons.refresh,
                size: 44,
                onPressed: () =>
                    ref.read(friendsLocationProvider.notifier).refresh(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OwnMarker extends StatelessWidget {
  const _OwnMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
    );
  }
}

class _FriendMarker extends StatelessWidget {
  final FriendLocationEntity friend;

  const _FriendMarker({required this.friend});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: friend.isOnline ? Colors.green : Colors.grey,
              width: 3,
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: friend.avatarUrl != null
                ? CachedNetworkImageProvider(friend.avatarUrl!)
                : null,
            child: friend.avatarUrl == null
                ? Text(
                    friend.displayName.isNotEmpty
                        ? friend.displayName[0].toUpperCase()
                        : '?',
                  )
                : null,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 2),
            ],
          ),
          child: Text(
            friend.displayName,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
