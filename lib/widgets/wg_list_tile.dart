import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

import '../data/wg_repository.dart';
import '../l10n/app_localizations.dart';
import 'navigation_bar.dart';

class WGListTile extends StatefulWidget {
  final String name;
  final int count;
  final String uid;
  final String username;

  const WGListTile(
      {super.key,
      required this.name,
      required this.count,
      required this.uid,
      required this.username});

  @override
  State<StatefulWidget> createState() => _WGListTileState();
}

class _WGListTileState extends State<WGListTile> {
  bool _joining = false;

  Future<void> _join() async {
    final auth = FirebaseAuth.instance;
    final uid = auth.currentUser?.uid;
    if (uid == null || _joining) return;

    setState(() => _joining = true);
    JoinResult result;
    try {
      result = await WgRepository.join(
        wgID: widget.uid,
        uid: uid,
        username: widget.username,
      );
    } catch (e) {
      debugPrint('Joining WG failed: $e');
      result = JoinResult.missing;
    }
    if (!mounted) return;
    setState(() => _joining = false);

    if (result != JoinResult.joined) {
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          result == JoinResult.full ? loc.wg_full : loc.wg_gone,
        ),
        duration: const Duration(seconds: 2),
      ));
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const NavBar(),
        ),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        widget.name,
        style: const TextStyle(fontSize: 20),
      ),
      enableFeedback: false,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SimpleCircularProgressBar(
            backColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            progressColors: [Theme.of(context).colorScheme.primary],
            mergeMode: true,
            size: 35,
            progressStrokeWidth: 3,
            backStrokeWidth: 3,
            maxValue: kDefaultMaxWgMembers.toDouble(),
            animationDuration: 1,
            fullProgressColor: Theme.of(context).colorScheme.error,
            onGetText: (_) {
              return Text("${widget.count}/$kDefaultMaxWgMembers");
            },
            valueNotifier: ValueNotifier(widget.count.toDouble()),
          ),
          const SizedBox(
            width: 15,
          ),
          ElevatedButton(
            // The capacity check that matters happens inside the join
            // transaction; this only keeps a full WG from looking tappable.
            onPressed:
                _joining || widget.count >= kDefaultMaxWgMembers ? null : _join,
            child: _joining
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right_rounded),
          )
        ],
      ),
    );
  }
}
