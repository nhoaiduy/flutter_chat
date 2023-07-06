import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ChangeInformationPage extends StatefulWidget {
  const ChangeInformationPage({Key? key}) : super(key: key);

  @override
  State<ChangeInformationPage> createState() => _ChangeInformationPageState();
}

class _ChangeInformationPageState extends State<ChangeInformationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool isEmailValidation = true;
  bool isNameValidation = true;

  String id = '';

  bool validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    return (regex.hasMatch(value)) ? true : false;
  }

  File? image;

  Future pickImage() async{
    try{
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(image == null) return;

      final imageTemporary = File(image.path);
      setState((){
        this.image = imageTemporary;
        print(image.path);
      });
    } on PlatformException catch(e){
      print('Failed to pick image:  $e');
    }
  }

  String? imageURL;

  Future saveInformation(String imageURL) async{
    if(nameController.text.isEmpty){
      setState((){
        isNameValidation = false;
        return;
      });
    }else{
      setState((){
        isNameValidation = true;
      });
    }

    if(image !=null){
      await FirebaseStorage.instance.ref().child('users').child(FirebaseAuth.instance.currentUser!.uid).child(image.toString()).putFile(image!);

      imageURL = await FirebaseStorage.instance.ref().child('users').child(FirebaseAuth.instance.currentUser!.uid).child(image.toString()).getDownloadURL();
    }

    Map<String, dynamic> map = {
      'userName': nameController.text,
      'image': imageURL,
    };

    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update(map);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Information'),
        actions: [
          TextButton(
              onPressed: () async{
                await saveInformation(imageURL.toString());
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 18),)
          )
        ],
      ),
      body: FutureBuilder(
          future: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get(),
          builder: (context,AsyncSnapshot<DocumentSnapshot> snapshot){
            UserModel userModel = UserModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);
            nameController.text = userModel.userName!;
            emailController.text = userModel.email!;
            imageURL = userModel.image!;
            return Padding(
              padding: const EdgeInsets.all(8),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child:  GestureDetector(
                          onTap: (){
                            pickImage();
                          },
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: image != null? Image.file(
                                image!,width: 64,
                                height: 64,
                                fit: BoxFit.cover,):
                              userModel.image!.isNotEmpty?
                              CachedNetworkImage(
                                imageUrl:   userModel.image!,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,):
                              Image.asset(
                                'assets/images/default_user_image.png',
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                              )
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24,),
                    TextField(
                      controller: nameController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                          labelText: "Name",
                          prefixIcon: const Icon(Icons.person),
                          border: const OutlineInputBorder(),
                          errorText: !isNameValidation ? "Please enter your name!" : null),
                    ),
                    const SizedBox(height: 12,),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      readOnly: true,
                      decoration: const InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),),
                    ),
                    const SizedBox(height: 12,),
                  ],
                ),
              ),
            );
      }),
    );
  }
}
