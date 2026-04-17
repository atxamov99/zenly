import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/user_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final ghostAsync = ref.watch(ghostModeProvider);

    return Scaffold(
      appBar: AppBar(
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
        error: (e, _) => Center(child: Text('Xato: $e')),
        data: (user) {
          if (user == null) return const SizedBox.shrink();
          return ListView(
            children: [
              const SizedBox(height: 16),
              Center(
                child: CircleAvatar(
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
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  user.displayName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Center(child: Text('@${user.username}')),
              if (user.email.isNotEmpty)
                Center(child: Text(user.email,
                    style: const TextStyle(color: Colors.grey))),
              const SizedBox(height: 24),
              const Divider(),
              SwitchListTile(
                secondary: const Icon(Icons.visibility_off),
                title: const Text('Ghost Mode'),
                subtitle: const Text("Joylashuvni vaqtincha yashirish"),
                value: ghostAsync.value ?? false,
                onChanged: ghostAsync.isLoading
                    ? null
                    : (v) => ref.read(ghostModeProvider.notifier).toggle(v),
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
                title:
                    Text('Maxfiylik', style: TextStyle(color: Colors.grey)),
                subtitle: Text('Tez orada'),
                enabled: false,
              ),
              const Divider(),
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
          );
        },
      ),
    );
  }
}
