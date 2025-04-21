import 'package:flutter/material.dart';
import 'package:wannabet/pages/view_profile.dart';

class ProfilePicture extends StatelessWidget {
  final String? profilePicture;
  final bool? searched;
  final bool? profile;
  final String? accountId;
  final user;

  const ProfilePicture({
    super.key,
    this.profilePicture,
    this.searched,
    this.profile,
    this.accountId,
    this.user
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: MediaQuery.of(context).size.width / (profile == true ? 6 : (searched == true ? 20 : 12)),
      backgroundColor: Colors.grey[300],
      backgroundImage: profilePicture != null 
          ? NetworkImage(profilePicture!) 
          : NetworkImage("http://www.gravatar.com/avatar/?d=mp"),
      child: GestureDetector(
        onTap: () {
          if (accountId != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewProfile(user: user, uid: accountId!)
                ),
              );
          }
        },
        child:Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
            color: Color(0xff231942),
            width: 1.0,
            ),
          ),
        )
      ),
    );
  }
}

