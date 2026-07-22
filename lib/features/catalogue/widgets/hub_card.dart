import 'dart:ui';

import 'package:flutter/material.dart';

// Card widgets for the Catalogue Screen
class HubCard extends StatelessWidget {
  final String label;
  final Widget leading;
  final VoidCallback onTap;
  const HubCard({super.key, required this.label, required this.leading, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 10,
      color: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Positioned.fill(child: leading),

            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Adjust blur intensity
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    color: Theme.of(context).colorScheme.scrim,
                    child: Text(
                      label,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
