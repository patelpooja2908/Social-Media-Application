import 'package:demo_social_media/bloc/auth_cubit.dart';
import 'package:demo_social_media/screens/chat_screen.dart';
import 'package:demo_social_media/screens/create_post_screen.dart';
import 'package:demo_social_media/screens/posts_screen.dart';
import 'package:demo_social_media/screens/sign_in_screen.dart';
import 'package:demo_social_media/screens/sign_up_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  // Check authState
  Widget _buildHomeScreen(User? user) {
    if (user != null) {
      if (user.emailVerified) {
        return const PostsScreen();
      } else {
        return const SignInScreen();
      }
    } else {
      return const SignInScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (context) => AuthCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            return _buildHomeScreen(snapshot.data);
          },
        ),
        routes: {
          SignUpScreen.routeName: (context) => const SignUpScreen(),
          SignInScreen.routeName: (context) => const SignInScreen(),
          PostsScreen.routeName: (context) => const PostsScreen(),
          CreatePostScreen.routeName: (context) => const CreatePostScreen(),
          ChatScreen.routeName: (context) => ChatScreen(),
        },
      ),
    );
  }
}

/*
import 'package:demo_social_media/bloc/auth_cubit.dart';
import 'package:demo_social_media/screens/chat_screen.dart';
import 'package:demo_social_media/screens/create_post_screen.dart';
import 'package:demo_social_media/screens/posts_screen.dart';
import 'package:demo_social_media/screens/sign_in_screen.dart';
import 'package:demo_social_media/screens/sign_up_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  // Check authState
  Widget _buildHomeScreen() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.emailVerified) {
            return const PostsScreen();
          }
          return const SignInScreen();
        } else {
          return const SignInScreen();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (context) => AuthCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(),
        home: _buildHomeScreen(),
        routes: {
          SignUpScreen.routeName: (context) => const SignUpScreen(),
          SignInScreen.routeName: (context) => const SignInScreen(),
          PostsScreen.routeName: (context) => const PostsScreen(), // Corrected route name
          CreatePostScreen.routeName: (context) => const CreatePostScreen(),
          ChatScreen.routeName: (context) =>  ChatScreen(),
        },
      ),
    );
  }
}
*/