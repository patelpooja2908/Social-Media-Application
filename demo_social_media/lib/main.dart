import 'package:demo_social_media/bloc/auth_cubit.dart';
import 'package:demo_social_media/screens/chat_screen.dart';
import 'package:demo_social_media/screens/create_post_screen.dart';
import 'package:demo_social_media/screens/posts_screen.dart';
import 'package:demo_social_media/screens/sign_in_screen.dart';
import 'package:demo_social_media/screens/sign_up_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (context) => AuthCubit(),
      child: MaterialApp(
        title: 'Demo Social Media App',
        theme: ThemeData.dark(),
        home: const SignInScreen(),
        routes: {
          //"/sign_up" : (context) => const SignUpScreen(),
          //"/sign_in_screen" : (context) => const SignInScreen(),
          //"/posts_screen" : (context) => const PostsScreen(),
          SignUpScreen.routeName: (context) => const SignUpScreen(),
          SignInScreen.routeName: (context) => const SignInScreen(),
          PostsScreen.routeName: (context) =>  PostsScreen(),
          CreatePostScreen.routeName: (context) =>  CreatePostScreen(),
          ChatScreen.routeName: (context) =>  ChatScreen(),
        },
      ),
    );
  }
}
