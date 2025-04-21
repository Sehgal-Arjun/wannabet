import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wannabet/widgets/notifications/notification_item.dart';

class NotificationGroup extends StatefulWidget {
  final String title;
  final bool startCollapsed;
  final bool collapsable;
  final List<Map<String, dynamic>> items;
  final user;

  const NotificationGroup({
    super.key,
    required this.title,
    this.startCollapsed = false,
    this.collapsable = true,
    required this.items,
    required this.user,
  });

  @override
  State<NotificationGroup> createState() => _NotificationGroupState();
}

class _NotificationGroupState extends State<NotificationGroup> {
  late bool isCollapsed;

  @override
  void initState() {
    super.initState();
    isCollapsed = widget.startCollapsed;
  }

  void toggleCollapse() {
    setState(() {
      isCollapsed = !isCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.title != "" ? Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: widget.collapsable ? toggleCollapse : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.lato(fontSize:22, color: Colors.black),
                  ),
                  if (widget.collapsable)
                    Icon(
                      isCollapsed ? Icons.arrow_right : Icons.arrow_drop_down,
                    ),
                ],
              ),
            ),
          ) : Padding(padding:EdgeInsets.zero),
          if (!isCollapsed)
            Column(
              children: widget.items.map((item) {
                return NotificationItem(
                  action: item['action'] ?? '',
                  profilePicture: item['profilePicture'] ?? '',
                  commentText: item['commentText'] ?? '',
                  username: item['username'] ?? '',
                  fullName: item['full_name'] ?? '',
                  friendId: item['id'] ?? '',
                  user: widget.user,
                  betAmount: item['bet_amount'] ?? '',
                  betTitle: item['bet_title'] ?? '',
                  betDescription: item['bet_description'] ?? '',
                  betId: item['bet_id'] ?? '',
                  notificationId: item['notification_id'] ?? '',
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
