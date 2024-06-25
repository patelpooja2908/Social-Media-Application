import 'package:demo_social_media/bloc/auth_cubit.dart';
import 'package:demo_social_media/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatefulWidget {
  static const String routeName = "/sign_up_screen";

  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final FocusNode _usernameFocusNode;
  late final FocusNode _passwordFocusNode;

  final _formKey = GlobalKey<FormState>();
  String _email = "";
  String _username = "";
  String _password = "";

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    context.read<AuthCubit>().signUpWithEmail(
      email: _email,
      username: _username,
      password: _password,
    );
  }

  @override
  void initState() {
    _usernameFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _usernameFocusNode.dispose();
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
                  if (state is AuthSignedUp) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Email Verification link has been sent, verify your Email and log in.",
                        ),
                      ),
                    );
                    Navigator.of(context).pushNamed(SignInScreen.routeName);
                  }
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Theme.of(context).errorColor,
                        content: Text(
                          state.message,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onError,
                          ),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 50),
                      // Image.asset(
                      //  'assets/logo.jpeg',
                      //   height: 100,
                      //   width: 100,
                      // ),
                      SizedBox(height: 20),
                      Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          fontFamily: GoogleFonts.pacifico().fontFamily,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        textCapitalization: TextCapitalization.none,
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        onSaved: (value) {
                          _email = value!.trim();
                        },
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_usernameFocusNode),
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
                        focusNode: _usernameFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_passwordFocusNode),
                        onSaved: (value) {
                          _username = value!.trim();
                        },
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please provide username...';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        focusNode: _passwordFocusNode,
                        textInputAction: TextInputAction.done,
                        obscureText: true,
                        onFieldSubmitted: (_) => _submit(),
                        onSaved: (value) {
                          _password = value!.trim();
                        },
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
                        onPressed: () {
                          _submit();
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed(SignInScreen.routeName),
                        child: Text(
                          'Already have an account?',
                          style: TextStyle(fontSize: 18),
                        ),
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
// sign_up_screen.dart

import 'package:demo_social_media/bloc/auth_cubit.dart';
import 'package:demo_social_media/screens/posts_screen.dart';
import 'package:demo_social_media/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpScreen extends StatefulWidget {

  static  const String routeName="/sign_up_screen";

  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String _email="";
  String _username="";
  String _password="";

  late final FocusNode _usernameFocusNode;
  late final FocusNode _PasswordFocusNode;

  final _formKey=GlobalKey<FormState>();
  void _submit()
  {
    FocusScope.of(context).unfocus();
    if(!_formKey.currentState!.validate()){
      //Invalid!
      return ;
    }
    _formKey.currentState!.save();
    context.read<AuthCubit>().signUpWithEmail(
        email: _email,
        username: _username,
        password: _password);
    //TODO:- ADD email verification
  }

  @override
  void initState() {
    // TODO: implement initState
    _usernameFocusNode=FocusNode();
    _PasswordFocusNode=FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _usernameFocusNode.dispose();
    _PasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Form(
            key: _formKey,
            child: BlocConsumer<AuthCubit,AuthState>(
                listener: (prevState,currentState){

                  if(currentState is AuthSignedUp){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "Email Verification link has been sent ,verify your Email and log in  "),
                      ),
                    );
                     Navigator.of(context).pushReplacementNamed(PostScreen.routeName);
                  }
                  if(currentState is AuthError){
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Theme.of(context).errorColor,
                        content: Text(currentState.message,style: TextStyle(color: Theme.of(context).colorScheme.onError),
                        ),
                        duration:const Duration(seconds: 2) ,
                      ),
                    );
                  }
                },
                builder: (context,state){
                  if(state is AuthLoading){
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.all(15),

                    children: [
                      //Email
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        textCapitalization: TextCapitalization.none,
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        onSaved: (value){
                          _email=value!.trim();
                        },
                        onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_usernameFocusNode),
                        decoration:const InputDecoration(
                            enabledBorder:  UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            labelText: "Enter email"),
                        validator: (value){
                          if(value == null || value.isEmpty){
                            return "Please Provide Email";
                          }
                          if(value.length<4)
                          {
                            return"Please Provide Longer Email...";
                          }
                          return null;
                        },

                      ),

                      //userName
                      TextFormField(
                        focusNode: _usernameFocusNode,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_PasswordFocusNode),
                        onSaved: (value){
                          _username=value!.trim();
                        },
                        decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            labelText: "Enter UserName"),

                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        validator: (value){
                          if(value == null || value.isEmpty){
                            return "Please Provide UserName";
                          }
                          if(value.length<4)
                          {
                            return"Please Provide Longer UserName...";
                          }
                          return null;
                        },


                      ),

                      //password

                      TextFormField(
                        focusNode: _PasswordFocusNode,
                        textInputAction: TextInputAction.done,
                        obscureText: true,
                        onFieldSubmitted: (_) => _submit(),
                        onSaved: (value){
                          _password=value!.trim();
                        },
                        decoration:const InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),

                            ),
                            labelText: "Enter Password"),
                        validator: (value){
                          if(value == null || value.isEmpty){
                            return "Please Provide Password";
                          }
                          if(value.length<4)
                          {
                            return"Please Provide Longer Password...";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 8,),
                      ElevatedButton(
                          onPressed: (){

                            _submit();

                          },
                          child: const Text("Sign Up")),
                      TextButton(onPressed: ()=>
                          Navigator.of(context).pushNamed(SignInScreen.routeName),
                        child:  const Text("Sign In Instead"),
                      ),
                    ],
                  );
                }
            ),
          ),
        ),
      ),
    );
  }
}
*/