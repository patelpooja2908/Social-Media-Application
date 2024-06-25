import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_social_media/screens/chat_screen.dart';
import 'package:demo_social_media/screens/create_post_screen.dart';
import 'package:demo_social_media/screens/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PostsScreen extends StatelessWidget {
  static const String routeName = "/posts_screen";

  const PostsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove back button
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            'Link Up..!!',
            style: TextStyle(
              fontSize: 22,
              fontFamily: GoogleFonts.pacifico().fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
              Navigator.of(context).pushNamed(ChatScreen.routeName);
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: StreamBuilder<QuerySnapshot>(
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
                final postRef = FirebaseFirestore.instance.collection("posts").doc(doc.id);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Profile/Username
                                Row(
                                  children: [
                                    Icon(Icons.account_circle), // User profile icon
                                    SizedBox(width: 8),
                                    Text(doc['userName'] ?? 'Anonymous', style: Theme.of(context).textTheme.headlineMedium),
                                  ],
                                ),
                                // Like Icon and Count
                                StreamBuilder<QuerySnapshot>(
                                  stream: postRef.collection('likes').snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    }
                                    final likes = snapshot.data!.docs.length;
                                    final isLiked = snapshot.data!.docs.any((like) => like.id == FirebaseAuth.instance.currentUser!.uid);
                                    return IconButton(
                                      onPressed: () async {
                                        final currentUser = FirebaseAuth.instance.currentUser!;
                                        if (isLiked) {
                                          await postRef.collection('likes').doc(currentUser.uid).delete();
                                        } else {
                                          await postRef.collection('likes').doc(currentUser.uid).set({'likedAt': Timestamp.now()});
                                        }
                                      },
                                      icon: Icon(
                                        isLiked ? Icons.favorite : Icons.favorite_border,
                                        color: isLiked ? Colors.red : null,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Image with Double Tap
                            GestureDetector(
                              onDoubleTap: () async {
                                final currentUser = FirebaseAuth.instance.currentUser!;
                                final isLiked = snapshot.data!.docs.any((like) => like.id == currentUser.uid);
                                if (isLiked) {
                                  await postRef.collection('likes').doc(currentUser.uid).delete();
                                } else {
                                  await postRef.collection('likes').doc(currentUser.uid).set({'likedAt': Timestamp.now()});
                                }
                              },
                              child: Image.network(doc['imageUrl'] ?? ''),
                            ),
                            const SizedBox(height: 6),
                            // Description
                            Text(doc['description'] ?? '', style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 6),
                            // Comment Section
                            CommentSection(postRef),
                            const SizedBox(height: 6),
                            // Like Count
                            StreamBuilder<QuerySnapshot>(
                              stream: postRef.collection('likes').snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }
                                final likes = snapshot.data!.docs.length;
                                return Text('Likes: $likes');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class CommentSection extends StatelessWidget {
  final DocumentReference postRef;

  const CommentSection(this.postRef, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Comments',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: postRef.collection('comments').orderBy('createdAt', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            final comments = snapshot.data!.docs;
            return Column(
              children: comments.map<Widget>((commentDoc) {
                final commentData = commentDoc.data() as Map<String, dynamic>;
                return ListTile(
                  leading: Icon(Icons.account_circle), // Profile icon
                  title: Text(commentData['userName']),
                  subtitle: Text(commentData['text']),
                );
              }).toList(),
            );
          },
        ),
        // Comment Form (To add a new comment)
        CommentForm(postRef),
      ],
    );
  }
}
class CommentForm extends StatefulWidget {
  final DocumentReference postRef;

  const CommentForm(this.postRef, {Key? key}) : super(key: key);

  @override
  _CommentFormState createState() => _CommentFormState();
}

class _CommentFormState extends State<CommentForm> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Type your comment...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () async {
              final currentUser = FirebaseAuth.instance.currentUser!;
              final commentText = _textController.text.trim();
              if (commentText.isNotEmpty) {
                await widget.postRef.collection('comments').add({
                  'text': commentText,
                  'userName': currentUser.displayName ?? 'Anonymous',
                  'userId': currentUser.uid,
                  'createdAt': Timestamp.now(),
                });
                _textController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_social_media/screens/chat_screen.dart';
import 'package:demo_social_media/screens/create_post_screen.dart';
import 'package:demo_social_media/screens/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
              Navigator.of(context).pushNamed(ChatScreen.routeName);
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: StreamBuilder<QuerySnapshot>(
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
                final postRef = FirebaseFirestore.instance.collection("posts").doc(doc.id);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Profile/Username
                                Row(
                                  children: [
                                    Icon(Icons.account_circle), // Profile icon
                                    SizedBox(width: 8),
                                    Text(doc['userName'] ?? 'Anonymous', style: Theme.of(context).textTheme.headlineMedium),
                                  ],
                                ),
                                // Like Icon and Count
                                StreamBuilder<QuerySnapshot>(
                                  stream: postRef.collection('likes').snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    }
                                    final likes = snapshot.data!.docs.length;
                                    final isLiked = snapshot.data!.docs.any((like) => like.id == FirebaseAuth.instance.currentUser!.uid);
                                    return IconButton(
                                      onPressed: () async {
                                        final currentUser = FirebaseAuth.instance.currentUser!;
                                        if (isLiked) {
                                          await postRef.collection('likes').doc(currentUser.uid).delete();
                                        } else {
                                          await postRef.collection('likes').doc(currentUser.uid).set({'likedAt': Timestamp.now()});
                                        }
                                      },
                                      icon: Icon(
                                        isLiked ? Icons.favorite : Icons.favorite_border,
                                        color: isLiked ? Colors.red : null,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Image with Double Tap
                            GestureDetector(
                              onDoubleTap: () async {
                                final currentUser = FirebaseAuth.instance.currentUser!;
                                final isLiked = snapshot.data!.docs.any((like) => like.id == currentUser.uid);
                                if (isLiked) {
                                  await postRef.collection('likes').doc(currentUser.uid).delete();
                                } else {
                                  await postRef.collection('likes').doc(currentUser.uid).set({'likedAt': Timestamp.now()});
                                }
                              },
                              child: Image.network(doc['imageUrl'] ?? ''),
                            ),
                            const SizedBox(height: 6),
                            // Description
                            Text(doc['description'] ?? '', style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 6),
                            // Comment Section
                            CommentSection(postRef),
                            const SizedBox(height: 6),
                            // Like Count
                            StreamBuilder<QuerySnapshot>(
                              stream: postRef.collection('likes').snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }
                                final likes = snapshot.data!.docs.length;
                                return Text('Likes: $likes');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class CommentSection extends StatelessWidget {
  final DocumentReference postRef;

  const CommentSection(this.postRef, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Comments',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: postRef.collection('comments').orderBy('createdAt', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            final comments = snapshot.data!.docs;
            return Column(
              children: comments.map<Widget>((commentDoc) {
                final commentData = commentDoc.data() as Map<String, dynamic>;
                return ListTile(
                  leading: Icon(Icons.account_circle), // Profile icon
                  title: Text(commentData['userName']),
                  subtitle: Text(commentData['text']),
                );
              }).toList(),
            );
          },
        ),
        // Comment Form (To add a new comment)
        CommentForm(postRef),
      ],
    );
  }
}

class CommentForm extends StatefulWidget {
  final DocumentReference postRef;

  const CommentForm(this.postRef, {Key? key}) : super(key: key);

  @override
  _CommentFormState createState() => _CommentFormState();
}

class _CommentFormState extends State<CommentForm> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Type your comment...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () async {
              final currentUser = FirebaseAuth.instance.currentUser!;
              final commentText = _textController.text.trim();
              if (commentText.isNotEmpty) {
                await widget.postRef.collection('comments').add({
                  'text': commentText,
                  'userName': currentUser.displayName ?? 'Anonymous',
                  'userId': currentUser.uid,
                  'createdAt': Timestamp.now(),
                });
                _textController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

*/

//==================================this above code is with like and comments section=================================

/*
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
              Navigator.pushNamed(context, ChatScreen.routeName);
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: StreamBuilder<QuerySnapshot>(
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
                final postRef = FirebaseFirestore.instance.collection("posts").doc(doc.id);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Profile/Username
                                Text(doc['userName'] ?? 'Anonymous', style: Theme.of(context).textTheme.headlineMedium),
                                // Like Icon and Count
                                StreamBuilder<QuerySnapshot>(
                                  stream: postRef.collection('likes').snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    }
                                    final likes = snapshot.data!.docs.length;
                                    final isLiked = snapshot.data!.docs.any((like) => like.id == FirebaseAuth.instance.currentUser!.uid);
                                    return IconButton(
                                      onPressed: () async {
                                        final currentUser = FirebaseAuth.instance.currentUser!;
                                        if (isLiked) {
                                          await postRef.collection('likes').doc(currentUser.uid).delete();
                                        } else {
                                          await postRef.collection('likes').doc(currentUser.uid).set({'likedAt': Timestamp.now()});
                                        }
                                      },
                                      icon: Icon(
                                        isLiked ? Icons.favorite : Icons.favorite_border,
                                        color: isLiked ? Colors.red : null,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Image
                            Image.network(doc['imageUrl'] ?? ''),
                            const SizedBox(height: 6),
                            // Description
                            Text(doc['description'] ?? '', style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 6),
                            // Comment Section (You can replace this with actual comment widget as per your requirement)
                            Row(
                              children: [
                                Icon(Icons.comment),
                                Text('Comments'),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Like Count
                            StreamBuilder<QuerySnapshot>(
                              stream: postRef.collection('likes').snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }
                                final likes = snapshot.data!.docs.length;
                                return Text('Likes: $likes');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
 */
//==========================above code is with like and count of like=============================
/*
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
              Navigator.pushNamed(context, ChatScreen.routeName);
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: StreamBuilder<QuerySnapshot>(
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
                final Post post = Post.fromSnapshot(doc);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Profile/Username
                                Text(post.userName, style: Theme.of(context).textTheme.headlineMedium),
                                // Like Icon
                                IconButton(
                                  onPressed: () {
                                    // Handle like functionality here
                                  },
                                  icon: Icon(Icons.favorite_border),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Image
                            Image.network(post.imageUrl),
                            const SizedBox(height: 6),
                            // Description
                            Text(post.description, style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 6),
                            // Comment Section (You can replace this with actual comment widget)
                            Row(
                              children: [
                                Icon(Icons.comment),
                                Text('Comments'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
*/
//=========================================above code is simple UI for like ========================================================
/*
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
              Navigator.pushNamed(context,ChatScreen.routeName);
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
              final Post post = Post.fromSnapshot(doc);

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
*/
//=========================================above code is simple post screen================================================