import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/chat': (context) => ChatScreen(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
          child: Text('Open Profile Screen'),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
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
              Navigator.pushNamed(context, '/chat', arguments: index);
            },
          );
        },
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final int? profileIndex = ModalRoute.of(context)!.settings.arguments as int?;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Screen'),
        backgroundColor: Colors.blue,
      ),
      body: ChatScreenBody(profileIndex: profileIndex),
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
