import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatelessWidget {
  static const String routeName = "/chat_screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            'Chat Screen',
            style: TextStyle(
              fontSize: 22,
              fontFamily: GoogleFonts.pacifico().fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: UserList(),
    );
  }
}

class UserList extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        List<DocumentSnapshot> users = snapshot.data!.docs;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            DocumentSnapshot user = users[index];
            return ListTile(
              leading: Icon(Icons.account_circle), // Profile icon
              title: Text(user['username'] ?? 'Anonymous'), // Assuming username is stored in 'username' field
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatScreenBody(user: user),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class ChatScreenBody extends StatelessWidget {
  final DocumentSnapshot user;

  const ChatScreenBody({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user['username'] ?? 'Anonymous'), // Assuming username is stored in 'username' field
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text('Chat with ${user['username']}'), // Assuming username is stored in 'username' field
            ),
          ),
          ChatInputField(user: user),
        ],
      ),
    );
  }
}

class ChatInputField extends StatelessWidget {
  final DocumentSnapshot user;

  const ChatInputField({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: () async {
              final currentUser = FirebaseAuth.instance.currentUser;
              final firestore = FirebaseFirestore.instance;
              final userRef = firestore.collection('users').doc(user.id);

              if (currentUser != null) {
                final message = 'Hello ${user['username']}, how are you?'; // Customize your message here
                await userRef.collection('messages').add({
                  'message': message,
                  'sender': currentUser.uid,
                  'timestamp': FieldValue.serverTimestamp(),
                });
              }
            },
            icon: Icon(Icons.send),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(),
    home: ChatScreen(),
  ));
}


/*
import 'package:flutter/material.dart';
import 'package:demo_social_media/screens/profile_screen.dart';

class ChatScreen extends StatelessWidget {
  static const String routeName = "/chat_screen";

  @override
  Widget build(BuildContext context) {
    final int? profileIndex = ModalRoute.of(context)!.settings.arguments as int?;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Screen'),
        backgroundColor: Colors.blue,
      ),
      body: ChatScreenBody(profileIndex: profileIndex),
      // Add Profile Icon Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(ProfileScreen.routeName);
        },
        child: const Icon(Icons.person),
      ),
    );
  }
}

class ChatScreenBody extends StatefulWidget {
  final int? profileIndex;

  const ChatScreenBody({Key? key, this.profileIndex}) : super(key: key);

  @override
  _ChatScreenBodyState createState() => _ChatScreenBodyState();
}

class _ChatScreenBodyState extends State<ChatScreenBody> {
  // Dummy data for chat messages
  List<Map<String, dynamic>> messages = [
    {'message': 'Hello!', 'isMe': false},
    {'message': 'Hi there!', 'isMe': true},
    {'message': 'How are you?', 'isMe': false},
    {'message': 'I\'m good, thanks!', 'isMe': true},
    {'message': 'What about you?', 'isMe': true},
    {'message': 'I\'m doing great!', 'isMe': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return ChatMessage(
                message: message['message'],
                isMe: message['isMe'],
              );
            },
          ),
        ),
        ChatInputField(),
      ],
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String message;
  final bool isMe;

  const ChatMessage({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class ChatInputField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.send),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
*/