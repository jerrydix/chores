import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String imagePath;
  final void Function() onTap;
  const AuthButton({super.key, required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.secondary,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        splashColor: Theme.of(context).colorScheme.surfaceTint.withValues(alpha: 0.75),
        enableFeedback: true,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.primary),
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Image.asset(
            imagePath,
            height: 40,
          ),
        ),
      ),
    );
  }
}