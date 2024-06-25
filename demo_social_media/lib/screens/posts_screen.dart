import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_social_media/screens/chat_screen.dart';
import 'package:demo_social_media/screens/create_post_screen.dart';
import 'package:demo_social_media/screens/profile_screen.dart';
import 'package:demo_social_media/screens/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/post_model.dart';

class PostsScreen extends StatelessWidget {
  static const String routeName = "/posts_screen";

  const PostsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // Add Post (Pick image and go to create post screen)
          IconButton(
            onPressed: () async {
              final ImagePicker imagePicker = ImagePicker();

              final XFile? xFile = await imagePicker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 50,
              );

              if (xFile != null) {
                Navigator.of(context).pushNamed(
                  CreatePostScreen.routeName,
                  arguments: File(xFile.path),
                );
              }
            },
            icon: const Icon(Icons.add, size: 30),
          ),
          // Chat Screen Icon Button
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, ProfileScreen.routeName);
            },
            icon: const Icon(Icons.chat, size: 30),
          ),

          // Log Out (Navigate back to Sign in screen)
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut().then(
                    (value) => Navigator.of(context).pushReplacementNamed(SignInScreen.routeName),
              );
            },
            icon: const Icon(Icons.logout, size: 30),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("posts").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError || snapshot.connectionState == ConnectionState.none) {
            return const Center(child: Text("Oops, something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final QueryDocumentSnapshot doc = snapshot.data!.docs[index];
              final Post post = Post(
                timestamp: doc["timeStamp"] as Timestamp,
                description: doc["description"] as String,
                imageUrl: doc["imageUrl"] as String,
                userId: doc["userId"] as String,
                userName: doc["userName"] as String,
              );

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Image.network(post.imageUrl),
                    const SizedBox(height: 6),
                    Text(post.userName, style: Theme.of(context).textTheme.headlineMedium),
                    Text(post.description, style: Theme.of(context).textTheme.headlineSmall),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_social_media/screens/create_post_screen.dart';
import 'package:demo_social_media/screens/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/post_model.dart';

class PostsScreen extends StatefulWidget {
  static const String routeName = "/posts_screen";


  @override
  _PostsScreenState createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {

  Future<List<Post>>?posts;

  @override
  void initState() {
    posts = FirebaseFirestore.instance.collection("posts").get().then((
        QuerySnapshot querySnapshot) {
      List<Post>posts = [];
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        posts.add(Post(userName: doc["userName"] as String,
          timestamp: doc["timeStamp"] as Timestamp,
          description: doc["description"] as String,
          userId: doc["userId"] as String,
          imageUrl: doc["imageUrl"] as String,
        ));
      }

      return posts;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          // Add Post (Pick image and go to create post screen)
          IconButton(
              onPressed: () async {
                final ImagePicker imagePicker = ImagePicker();

                final XFile? xFile = await imagePicker.pickImage(
                    source: ImageSource.gallery, imageQuality: 50);

                if (xFile != null) {
                  Navigator.of(context).pushNamed(
                      CreatePostScreen.routeName,
                      arguments: File(xFile.path)
                  );
                }
              },
              icon: const Icon(Icons.add, size: 30)),

          IconButton(onPressed: () {
            FirebaseAuth.instance.signOut().then((value) =>
                Navigator.of(context).pushReplacementNamed(
                    SignInScreen.routeName),
            );
          }, icon: const Icon(Icons.logout, size: 30)),
        ],
      ),
      body: FutureBuilder(
          future: posts,
          builder: (BuildContext context, AsyncSnapshot<List<Post>> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Center(child: Text("No connection"));
              case ConnectionState.waiting:
              case ConnectionState.active:
                return const Center(child: CircularProgressIndicator());
              case ConnectionState.done:
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final Post post = snapshot.data![index];

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Image.network(post.imageUrl),
                          const SizedBox(height: 6),
                          Text(post.userName,
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .headlineMedium),
                        ],
                      ),
                    );
                  },
                );
            }
          }),
    );
  }
}
*/