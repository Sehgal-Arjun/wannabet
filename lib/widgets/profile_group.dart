import 'package:flutter/material.dart';

class ProfileGroup extends StatelessWidget {
  final List<String> imageUrls;
  final double imageSize;
  final int maxVisible;

  const ProfileGroup({
    super.key,
    required this.imageUrls,
    this.imageSize = 25,
    this.maxVisible = 4,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: imageSize, // Ensure Stack has a defined height
      width: (maxVisible + 1) * (imageSize * 0.6), // Adjust width dynamically
      child: Stack(
        clipBehavior: Clip.none, // Allow overflow for overlapping effect
        children: imageUrls.take(maxVisible).toList().asMap().entries.map((entry) {
          int index = entry.key;
          String url = entry.value;
          return Positioned(
            left: index * (imageSize * 0.6), // Overlapping effect
            child: CircleAvatar(
              radius: imageSize / 2,
              backgroundImage: NetworkImage(url),
              backgroundColor: Colors.grey[300],
            ),
          );
        }).toList()
          ..addAll(
            imageUrls.length > maxVisible ? [
              Positioned(
                left: maxVisible * (imageSize * 0.6),
                child: CircleAvatar(
                  radius: imageSize / 2,
                  backgroundColor: Colors.grey[500],
                  child: Text(
                    "+${imageUrls.length - maxVisible}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: imageSize * 0.4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ] : [],
          ),
      ),
    );
  }
}
