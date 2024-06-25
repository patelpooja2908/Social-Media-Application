import 'package:flutter/material.dart';
import 'package:demo_social_media/screens/chat_screen.dart';

class ProfileScreen extends StatelessWidget {
  static const String routeName = "/profile_screen";

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Screen'),
      ),
      body: ListView.builder(
        itemCount: 10, // Assuming there are 10 profiles
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Person $index'),
            onTap: () {
              Navigator.pushNamed(context, ChatScreen.routeName, arguments: index);
            },
          );
        },
      ),
    );
  }
}
