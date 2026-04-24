import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/glass/glass_app_bar.dart';
import '../../widgets/glass/glass_background.dart';
import '../../widgets/glass/glass_card.dart';
import '../../widgets/glass/glass_empty_state.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final ghostAsync = ref.watch(ghostModeProvider);

    return GlassBackground(
      child: Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar(
        title: const Text('Sozlamalar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push(AppRoutes.profileSetup),
          ),
        ],
      ),
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
          return ListView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
              bottom: 120,
            ),
            children: [
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.grey.shade200,
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
                          style: const TextStyle(color: Colors.grey)),
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
                          : (v) =>
                              ref.read(ghostModeProvider.notifier).toggle(v),
                    ),
                    const ListTile(
                      leading: Icon(Icons.battery_charging_full,
                          color: Colors.grey),
                      title: Text('Batareya ulashish',
                          style: TextStyle(color: Colors.grey)),
                      subtitle: Text('Tez orada'),
                      enabled: false,
                    ),
                    const ListTile(
                      leading: Icon(Icons.lock_outline, color: Colors.grey),
                      title: Text('Maxfiylik',
                          style: TextStyle(color: Colors.grey)),
                      subtitle: Text('Tez orada'),
                      enabled: false,
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
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text("Chiqish",
                          style: TextStyle(color: Colors.red)),
                      onTap: () async {
                        await ref.read(authStateProvider.notifier).signOut();
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      ),
    );
  }
}

