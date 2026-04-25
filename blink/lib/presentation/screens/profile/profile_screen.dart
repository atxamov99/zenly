import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/user_provider.dart';
import '../../../core/theme/glass_tokens.dart';
import '../../widgets/glass/glass_background.dart';
import '../../widgets/glass/glass_card.dart';
import '../../widgets/glass/glass_empty_state.dart';
import '../../widgets/glass/glass_sliver_app_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final ghostAsync = ref.watch(ghostModeProvider);

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => GlassEmptyState(
            icon: Icons.cloud_off,
            title: "Profilni yuklab bo'lmadi",
            detail: '$e',
            onRetry: () => ref.invalidate(currentUserProvider),
          ),
          data: (user) {
            if (user == null) {
              return const GlassEmptyState(
                icon: Icons.person_off_outlined,
                title: 'Profil topilmadi',
                detail: 'Iltimos, qayta kiring.',
              );
            }
            return CustomScrollView(
              slivers: [
                GlassSliverAppBar(
                  title: const Text('Sozlamalar'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => context.push(AppRoutes.profileSetup),
                    ),
                  ],
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),
                    GlassCard(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24, horizontal: 16),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: const Color(0x33FFFFFF),
                            backgroundImage: user.photoUrl.isNotEmpty
                                ? CachedNetworkImageProvider(user.photoUrl)
                                : null,
                            child: user.photoUrl.isEmpty
                                ? Text(
                                    user.displayName.isNotEmpty
                                        ? user.displayName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(fontSize: 32),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user.displayName,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text('@${user.username}'),
                          if (user.email.isNotEmpty)
                            Text(user.email,
                                style: TextStyle(color: GlassTokens.onGlassMuted)),
                        ],
                      ),
                    ),
                    GlassCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          SwitchListTile(
                            secondary: const Icon(Icons.visibility_off),
                            title: const Text('Ghost Mode'),
                            subtitle:
                                const Text("Joylashuvni vaqtincha yashirish"),
                            value: ghostAsync.value ?? false,
                            onChanged: ghostAsync.isLoading
                                ? null
                                : (v) => ref
                                    .read(ghostModeProvider.notifier)
                                    .toggle(v),
                          ),
                          const _PrivacySection(),
                        ],
                      ),
                    ),
                    GlassCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.place_outlined),
                            title: const Text('Joylarim'),
                            subtitle:
                                const Text("Uy / Maktab / Ish — geozone'lar"),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.push(AppRoutes.geozones),
                          ),
                        ],
                      ),
                    ),
                    GlassCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          const ListTile(
                            leading: Icon(Icons.info_outline),
                            title: Text('Ilova haqida'),
                            subtitle: Text('v1.0.0'),
                          ),
                          ListTile(
                            leading:
                                const Icon(Icons.logout, color: Colors.red),
                            title: const Text("Chiqish",
                                style: TextStyle(color: Colors.red)),
                            onTap: () async {
                              await ref
                                  .read(authStateProvider.notifier)
                                  .signOut();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 120),
                  ]),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

String _visibilityLabel(String value) {
  switch (value) {
    case 'circles':
      return "Doiralarim";
    case 'nobody':
      return "Hech kim";
    case 'friends':
    default:
      return "Do'stlar";
  }
}

class _PrivacySection extends ConsumerWidget {
  const _PrivacySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(privacyProvider);
    return async.when(
      loading: () => const ListTile(
        leading: Icon(Icons.lock_outline),
        title: Text("Maxfiylik"),
        trailing: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (e, _) => ListTile(
        leading: const Icon(Icons.lock_outline, color: Colors.red),
        title: const Text("Maxfiylik"),
        subtitle: Text('$e', style: const TextStyle(color: Colors.red)),
      ),
      data: (privacy) => Column(
        children: [
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text("Joylashuv ko'rinishi"),
            subtitle: Text(_visibilityLabel(privacy.locationVisibility)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickVisibility(
              context,
              current: privacy.locationVisibility,
              title: "Joylashuvni kim ko'radi?",
              onPicked: (v) =>
                  ref.read(privacyProvider.notifier).setLocationVisibility(v),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.battery_charging_full),
            title: const Text("Batareya ulashish"),
            subtitle: Text(_visibilityLabel(privacy.batteryVisibility)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickVisibility(
              context,
              current: privacy.batteryVisibility,
              title: "Batareyani kim ko'radi?",
              onPicked: (v) =>
                  ref.read(privacyProvider.notifier).setBatteryVisibility(v),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text("Oxirgi faollik"),
            subtitle: Text(_visibilityLabel(privacy.lastSeenVisibility)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _pickVisibility(
              context,
              current: privacy.lastSeenVisibility,
              title: "Oxirgi faollikni kim ko'radi?",
              onPicked: (v) =>
                  ref.read(privacyProvider.notifier).setLastSeenVisibility(v),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickVisibility(
    BuildContext context, {
    required String current,
    required String title,
    required ValueChanged<String> onPicked,
  }) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            for (final value in const ['friends', 'circles', 'nobody'])
              RadioListTile<String>(
                title: Text(_visibilityLabel(value)),
                value: value,
                groupValue: current,
                onChanged: (v) => Navigator.of(ctx).pop(v),
              ),
          ],
        ),
      ),
    );
    if (picked != null && picked != current) onPicked(picked);
  }
}
