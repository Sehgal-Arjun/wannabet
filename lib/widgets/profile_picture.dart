import 'package:flutter/material.dart';
import 'package:wannabet/pages/view_profile.dart';

class ProfilePicture extends StatelessWidget {

  const ProfilePicture({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ViewProfile()),
        );
      },
      child: CircleAvatar(
        radius: MediaQuery.of(context).size.width / 12,
        backgroundColor: Colors.grey[300],
        backgroundImage: NetworkImage("http://www.gravatar.com/avatar/?d=mp"),
        child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
          color: Color(0xff231942),
          width: 1.0,
          ),
        ),
        ),
      ),
    );
  }
}
