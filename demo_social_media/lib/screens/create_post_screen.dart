import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:image_picker/image_picker.dart';

class CreatePostScreen extends StatefulWidget {
  static const String routeName = "/create_post_screen";

  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  String _description = "";
  late File _image;

  @override
  void initState() {
    super.initState();
    _getImage();
  }

  void _getImage() async {
    final ImagePicker imagePicker = ImagePicker();
    final XFile? xFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (xFile != null) {
      setState(() {
        _image = File(xFile.path);
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    // Write image to storage
    final storage.FirebaseStorage firebaseStorage =
        storage.FirebaseStorage.instance;
    final storage.Reference storageRef =
    firebaseStorage.ref().child("images/${_image.path}");

    storage.UploadTask uploadTask = storageRef.putFile(_image);
    storage.TaskSnapshot taskSnapshot = await uploadTask;
    String imageUrl = await taskSnapshot.ref.getDownloadURL();

    // Add to cloud firestore
    final CollectionReference collectionReference =
    FirebaseFirestore.instance.collection("posts");

    await collectionReference.add({
      "userId": FirebaseAuth.instance.currentUser!.uid,
      "description": _description,
      "timeStamp": Timestamp.now(),
      "userName": FirebaseAuth.instance.currentUser!.displayName,
      "imageUrl": imageUrl,
    });

    // Pop the screen
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _image != null
          ? Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Image.file(_image, fit: BoxFit.cover),
            // Description Text Field
            TextFormField(
              onSaved: (value) {
                _description = value!;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please provide description";
                }
                return null;
              },
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              autocorrect: false,
              textCapitalization: TextCapitalization.none,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text('Post'),
            ),
          ],
        ),
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}




/*
class CreatePostScreen extends StatefulWidget {

  static const String routeName = "/create_post_screen";

  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {

   final _formKey = GlobalKey<FormState>();

   String _description = "";

  Future<void> _submit(File image) async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    //  Todo: Write image and description to database
    // Write image to storage
    storage.FirebaseStorage firebaseStorage = storage.FirebaseStorage.instance;
    late String imageUrl;

    await firebaseStorage.ref("image/${UniqueKey().toString()}.png").putFile(image).then((taskSnapshot) async {
      imageUrl = await taskSnapshot.ref.getDownloadURL();
    });


    // Add to cloud firestore
    final CollectionReference collectionReference = FirebaseFirestore.instance.collection("posts");

    collectionReference.add(
        {
          "userId": FirebaseAuth.instance.currentUser!.uid,
          "description": _description,
          "timeStamp": Timestamp.now(),
          "userName": FirebaseAuth.instance.currentUser!.displayName,
          "imageUrl" : imageUrl,
          //"postID" : ""
          //}).then((docReference) => docReference.update({"postID" : docReference.id}));
        });

    // Pop the screen
    Navigator.of(context).pop();
   }

  @override
  Widget build(BuildContext context) {

    final File image = ModalRoute.of(context)!.settings.arguments as File;

    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Image.file(image, fit: BoxFit.cover),
            // Description Text Field
            TextFormField(
              onSaved: (value) {
                _description = value!;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please provide description";
                }
                return null;
              },
              decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  )
              ),
              autocorrect: false,
              textCapitalization: TextCapitalization.none,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(image),

            )
          ],
        ),
      ),
    );
  }
}
*/