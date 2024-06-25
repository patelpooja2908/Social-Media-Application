// sign_in_screen.dart

import 'package:demo_social_media/bloc/auth_cubit.dart';
import 'package:demo_social_media/screens/posts_screen.dart';
import 'package:demo_social_media/screens/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInScreen extends StatefulWidget {
  static const String routeName = "/sign_in_screen";

  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late String _email;
  late String _password;

  late final FocusNode _passwordFocusNode;

  final _formKey = GlobalKey<FormState>();

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }

    _formKey.currentState!.save();

    //TODO: Authenticate with email and password
    context.read<AuthCubit>().signInWithEmail(email: _email, password: _password);
  }

  @override
  void initState() {
    _passwordFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthSignedIn) {
                    Navigator.of(context).pushReplacementNamed(PostsScreen.routeName);
                  }
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.message,
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 50),
                      Image.asset(
                        'assets/logo.jpeg',
                        height: 100,
                        width: 100,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        textCapitalization: TextCapitalization.none,
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        onSaved: (value) => _email = value!,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please provide email...';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        focusNode: _passwordFocusNode,
                        textInputAction: TextInputAction.done,
                        obscureText: true,
                        onSaved: (value) => _password = value!,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please provide password...';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: _submit,
                        child: Text(
                          'Login In',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed(SignUpScreen.routeName),
                        child: Text('Create an account?',style: TextStyle(fontSize: 18),),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/*
import 'package:demo_social_media/bloc/auth_cubit.dart';
import 'package:demo_social_media/screens/posts_screen.dart';
import 'package:demo_social_media/screens/sign_up_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInScreen extends StatefulWidget {

  static const String routeName = "/sign_in_screen";

  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  String _email = "";
  String _password = "";

  late final FocusNode _passwordFocusNode;

  final _formKey = GlobalKey<FormState>();

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }

    _formKey.currentState!.save();

    //TODO: Authenicate with email and password
    context
        .read<AuthCubit>()
        .signInWithEmail(email: _email, password: _password);
  }


  @override
  void initState() {
    _passwordFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (prevState, currState) {
              if (currState is AuthError) {

                ScaffoldMessenger.of(context).removeCurrentSnackBar();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    content: Text(
                      currState.message,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onError),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }

              if (currState is AuthSignedIn) {
                // if (!FirebaseAuth.instance.currentUser!.emailVerified) {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     const SnackBar(
                //       content: Text("Verify your email"),
                //     ),
                //   );
                // }
                 Navigator.of(context)
                    .pushReplacementNamed(PostsScreen.routeName);
              }
            },
            builder: (context, state) {
              if (state is AuthLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(15.0),

                children: [
                  //Email
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    onSaved: (value) {
                      _email = value!.trim();
                    },
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_passwordFocusNode),
                    decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        labelText: "Enter email"
                    ),
                  ),

                  //Password
                  TextFormField(
                    focusNode: _passwordFocusNode,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSaved: (value) {
                      _password = value!.trim();
                    },
                    onFieldSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      labelText: "Enter password",
                    ),

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please provide password...";
                      }

                      if (value.length < 5) {
                        return "Please provide longer password...";
                      }
                      return null;
                    },
                  ),

                  ElevatedButton(
                      onPressed: () => _submit(),
                      child: const Text("Log In")),

                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(SignUpScreen.routeName),
                    child: const Text("Sign Up Instead"),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
*/