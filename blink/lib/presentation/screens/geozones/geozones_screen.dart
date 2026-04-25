import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../domain/entities/geozone_entity.dart';
import '../../providers/geozone_provider.dart';
import '../../widgets/glass/glass_app_bar.dart';
import '../../widgets/glass/glass_card.dart';

class GeozonesScreen extends ConsumerWidget {
  const GeozonesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(geozonesProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: const Text('Joylarim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(AppRoutes.newGeozone),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + kToolbarHeight,
          ),
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Xato: $e')),
            data: (geozones) {
              if (geozones.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 64, color: Colors.black26),
                        const SizedBox(height: 16),
                        const Text(
                          "Hali joylar yo'q",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Uy, ish, maktab — joylaringizni belgilash do'stlarga 'qayerda?' deb yozishni qisqartiradi.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () => context.push(AppRoutes.newGeozone),
                          icon: const Icon(Icons.add),
                          label: const Text("Joy qo'shish"),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () =>
                    ref.read(geozonesProvider.notifier).refresh(),
                child: ListView.builder(
                  itemCount: geozones.length,
                  itemBuilder: (_, i) =>
                      _GeozoneTile(geozone: geozones[i]),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GeozoneTile extends ConsumerWidget {
  final GeozoneEntity geozone;
  const _GeozoneTile({required this.geozone});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(geozone.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(geozone.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                Text(
                  '${geozone.radiusMeters.round()}m radius · '
                  '${geozone.notifyViewerIds.length} kuzatuvchi',
                  style:
                      const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Colors.red, size: 22),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text("'${geozone.name}'ni o'chirish?"),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Bekor')),
                    FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("O'chirish")),
                  ],
                ),
              );
              if (ok == true) {
                try {
                  await ref
                      .read(geozonesProvider.notifier)
                      .delete(geozone.id);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Xato: $e')));
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
