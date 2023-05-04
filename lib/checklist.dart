import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChecklistPage extends StatefulWidget {
  final String title;
  final List<String> list;

  const ChecklistPage({super.key, required this.title, required this.list});

  @override
  State<ChecklistPage> createState() => _ChecklistState();
}

class _ChecklistState extends State<ChecklistPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: const Center(
        child: Text('lmao'),
      ),
    );
  }
}
