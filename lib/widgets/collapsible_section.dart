import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CollapsibleSection extends StatefulWidget {
  final String title;
  final List<Widget> children;

  const CollapsibleSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16), // Reduced margin
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xff231942)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12), // Minimal padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Column(
              children: widget.children
                  .map((child) => Container(
                        padding: const EdgeInsets.symmetric(vertical: 2), // Almost no spacing
                        child: child,
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}
