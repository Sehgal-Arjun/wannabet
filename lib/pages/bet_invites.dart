import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:wannabet/widgets/notifications/notification_group.dart';

class BetInvitesPage extends StatefulWidget {
  final List<Map<String, dynamic>> betInvites;
  final user;
  const BetInvitesPage({super.key, required this.betInvites, required this.user});

  @override
  State<BetInvitesPage> createState() => _BetInvitesPageState();
}

class _BetInvitesPageState extends State<BetInvitesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bet Invites'),
        centerTitle: true,
      ),
      body: widget.betInvites.isEmpty
          ? Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          Lottie.asset(
            'assets/noBetInvitesAnimation.json',
            width: MediaQuery.of(context).size.width / 1.25,
            height: MediaQuery.of(context).size.width / 1.25,
          ),
          Text(
            'No bet invites yet',
            style: GoogleFonts.lato(color: Colors.black, fontSize: 16),
          ),
            ],
          ),
        )
        : widget.betInvites.isNotEmpty ? NotificationGroup(
          title: '',
          startCollapsed: false,
          collapsable: false,
          items: [
            for (var invite in widget.betInvites)
              {
                'action': 'bet_invite',
                'profilePicture': invite['profile_picture'] ?? invite['from_profile_picture'] ?? 'http://www.gravatar.com/avatar/?d=mp',
                'username': invite['from_username'] ?? 'unknown',
                'full_name': invite['from_full_name'] ?? 'Unknown User',
                'id': invite['from_user_id'],
                'bet_title': invite['title'] ?? 'Unknown Bet',
                'bet_amount': (invite['amount'] ?? 'Unknown Bet Amount').toString(),
                'bet_description': invite['description'] ?? 'No bet description',
                'bet_id': invite['bet_id'],
                'notification_id': invite['notification_id'],
              },
          ],
          user: widget.user,
        )
      : Container(),
    );
  }
}