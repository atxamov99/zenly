import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/glass_tokens.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/friends_provider.dart';
import '../../../widgets/glass/glass_card.dart';
import '../../../widgets/glass/glass_surface.dart';
import 'friend_tile.dart';
import 'qr_scan_screen.dart';
import 'qr_show_dialog.dart';

class AddFriendTab extends ConsumerStatefulWidget {
  const AddFriendTab({super.key});

  @override
  ConsumerState<AddFriendTab> createState() => _AddFriendTabState();
}

class _AddFriendTabState extends ConsumerState<AddFriendTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(friendSearchProvider.notifier).search(value);
    });
  }

  Future<void> _showMyQr() async {
    final storage = ref.read(tokenStorageProvider);
    final userId = await storage.getUserId();
    if (userId == null || !mounted) return;
    await showGeneralDialog<void>(
      context: context,
      barrierLabel: 'QR oynasini yopish',
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => QrShowDialog(username: userId),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(curved),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 0.94,
                end: 1,
              ).animate(curved),
              child: child,
            ),
          ),
        );
      },
    );
  }

  Future<void> _scanQr() async {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const QrScanScreen()),
    );
  }

  Future<void> _sendRequest(String username) async {
    try {
      await ref.read(friendRequestsProvider.notifier).sendRequest(username);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("So'rov yuborildi")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xato: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(friendSearchProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassSurface(
            radius: GlassTokens.radiusButton,
            tintOpacity: 0.35,
            blur: GlassTokens.blurThin,
            specular: false,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.black54),
                hintText: 'Username qidiring',
                hintStyle: TextStyle(color: Colors.black45),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(color: Colors.black87),
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  onTap: _showMyQr,
                  margin: EdgeInsets.zero,
                  radius: GlassTokens.radiusButton,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code, size: 18, color: Colors.black87),
                      SizedBox(width: 8),
                      Text("QR ko'rsatish",
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassCard(
                  onTap: _scanQr,
                  margin: EdgeInsets.zero,
                  radius: GlassTokens.radiusButton,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner,
                          size: 18, color: Colors.black87),
                      SizedBox(width: 8),
                      Text('Skanerlash',
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: searchAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Xato: $e')),
              data: (results) {
                if (_searchCtrl.text.trim().isEmpty) {
                  return const Center(
                    child: Text('Qidirish uchun yozing'),
                  );
                }
                if (results.isEmpty) {
                  return const Center(child: Text('Hech kim topilmadi'));
                }
                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (_, i) {
                    final user = results[i];
                    return FriendTile(
                      friend: user,
                      trailing: IconButton(
                        icon: const Icon(Icons.person_add, color: Colors.blue),
                        onPressed: () => _sendRequest(user.username),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
