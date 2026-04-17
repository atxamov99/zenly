import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/entities/friend_request_entity.dart';
import '../../../providers/friends_provider.dart';

class RequestsTab extends ConsumerWidget {
  const RequestsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reqAsync = ref.watch(friendRequestsProvider);

    return reqAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Xato: $e')),
      data: (data) {
        if (data.incoming.isEmpty && data.outgoing.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text("Yangi so'rovlar yo'q"),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () =>
              ref.read(friendRequestsProvider.notifier).refresh(),
          child: ListView(
            children: [
              if (data.incoming.isNotEmpty) ...[
                const _SectionHeader(title: 'Kelganlar'),
                ...data.incoming.map((r) => _IncomingTile(request: r)),
              ],
              if (data.outgoing.isNotEmpty) ...[
                const _SectionHeader(title: 'Yuborilganlar'),
                ...data.outgoing.map((r) => _OutgoingTile(request: r)),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}

class _IncomingTile extends ConsumerWidget {
  final FriendRequestEntity request;
  const _IncomingTile({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: _Avatar(url: request.avatarUrl, name: request.displayName),
      title: Text(request.displayName.isNotEmpty
          ? request.displayName
          : request.username),
      subtitle: Text('@${request.username}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green),
            onPressed: () => _respond(context, ref, true),
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            onPressed: () => _respond(context, ref, false),
          ),
        ],
      ),
    );
  }

  Future<void> _respond(BuildContext context, WidgetRef ref, bool accept) async {
    try {
      await ref
          .read(friendRequestsProvider.notifier)
          .respond(request.requestId, accept: accept);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xato: $e')),
        );
      }
    }
  }
}

class _OutgoingTile extends ConsumerWidget {
  final FriendRequestEntity request;
  const _OutgoingTile({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: _Avatar(url: request.avatarUrl, name: request.displayName),
      title: Text(request.displayName.isNotEmpty
          ? request.displayName
          : request.username),
      subtitle: Text('@${request.username}'),
      trailing: TextButton(
        onPressed: () async {
          try {
            await ref
                .read(friendRequestsProvider.notifier)
                .cancel(request.requestId);
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Xato: $e')),
              );
            }
          }
        },
        child: const Text('Bekor qilish'),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String name;
  const _Avatar({required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: url != null ? CachedNetworkImageProvider(url!) : null,
      child: url == null
          ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?')
          : null,
    );
  }
}
