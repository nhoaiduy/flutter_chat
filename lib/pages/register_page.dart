import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController confirmPWwController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  bool showPW = false;
  bool showConfirmPW = false;
  bool isEmailValidation = true;
  bool isPWValidation = true;
  bool isNameValidation = true;
  bool isConfirmPWValidation = true;

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

  Future<void> register() async {
    if (isPWValidation && isEmailValidation && isNameValidation && isConfirmPWValidation) {
      if(pwController.text == confirmPWwController.text){
        try {
          await auth.createUserWithEmailAndPassword(email: emailController.text, password: pwController.text).then((value) {
            setState(() {
              id= value.user!.uid;
            });
          });

          String imageURL = '';
          if(image !=null){
            await FirebaseStorage.instance.ref().child('users').child(id).child(image.toString()).putFile(image!);

            imageURL = await FirebaseStorage.instance.ref().child('users').child(id).child(image.toString()).getDownloadURL();
          }

          Map<String, dynamic> map = {
            'userID': id,
            'userName': nameController.text,
            'email': emailController.text,
            'image': imageURL.isNotEmpty?imageURL:'',
            'token': '',
          };

          FirebaseFirestore.instance.collection('users')..doc(map['userID']).set(map).then((value){
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Register successfully"),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
            ));
            Navigator.pop(context);
          });
        } on FirebaseAuthException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.message.toString()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ));
        }
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Password does not match'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
            color: Colors.purple
        ),
      ),
      body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(8),
            width: MediaQuery.of(context).size.width,
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Register', style: TextStyle(color: Colors.purple, fontSize: 28, fontWeight: FontWeight.bold) ),
                const SizedBox(height: 24,),
                Center(
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
                        Image.asset(
                          'assets/images/default_user_image.png',
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        )
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
                  onChanged: (text) {
                    setState(() {
                      if (nameController.text.isEmpty) {
                        isNameValidation = false;
                      } else {
                        isNameValidation = true;
                      }
                    });
                  },
                  onTap: () {
                    setState(() {
                      if (nameController.text.isEmpty) {
                        isNameValidation = false;
                      }
                    });
                  },
                ),
                const SizedBox(height: 12,),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email),
                      border: const OutlineInputBorder(),
                      errorText: !isEmailValidation ? "Email invalidate!" : null),
                  onChanged: (text) {
                    setState(() {
                      isEmailValidation = validateEmail(emailController.text);
                    });
                  },
                  onTap: () {
                    setState(() {
                      if (emailController.text.isEmpty) {
                        isEmailValidation = false;
                      }
                    });
                  },
                ),
                const SizedBox(height: 12,),
                TextField(
                  controller: pwController,
                  obscureText: !showPW,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      errorText:
                      !isPWValidation ? "Please enter a password!" : null,
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            showPW = !showPW;
                          });
                        },
                        child: !showPW
                            ? const Icon(Icons.visibility)
                            : const Icon(Icons.visibility_off),
                      )),
                  onChanged: (text) {
                    setState(() {
                      if (pwController.text.length < 6) {
                        isPWValidation = false;
                      } else {
                        isPWValidation = true;
                      }
                    });
                  },
                  onTap: () {
                    setState(() {
                      if (pwController.text.length < 6) {
                        isPWValidation = false;
                      }
                    });
                  },
                ),
                const SizedBox(height: 12,),
                TextField(
                  controller: confirmPWwController,
                  obscureText: !showConfirmPW,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                      labelText: "Confirm Password",
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      errorText:
                      !isConfirmPWValidation ? "Please enter a password!" : null,
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            showConfirmPW = !showConfirmPW;
                          });
                        },
                        child: !showConfirmPW
                            ? const Icon(Icons.visibility)
                            : const Icon(Icons.visibility_off),
                      )),
                  onChanged: (text) {
                    setState(() {
                      if (confirmPWwController.text.length < 6) {
                        isConfirmPWValidation = false;
                      } else {
                        isConfirmPWValidation = true;
                      }
                    });
                  },
                  onTap: () {
                    setState(() {
                      if (confirmPWwController.text.length < 6) {
                        isConfirmPWValidation = false;
                      }
                    });
                  },
                ),
                const SizedBox(height: 24,),
                ElevatedButton(
                    onPressed: () {
                      register();
                    },
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 32,
                      height: 48,
                      child: const Center(
                          child: Text(
                            "Regiter",
                            style: TextStyle(fontSize: 18),
                          )),
                    )),
              ],
            ),
          )
      ),
    );
  }
}
