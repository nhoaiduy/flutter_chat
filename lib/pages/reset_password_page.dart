import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat/pages/pages.dart';
import 'package:flutter/services.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {

  final TextEditingController emailController = TextEditingController();

  FirebaseAuth auth= FirebaseAuth.instance;

  bool isEmailValidation = true;

  bool validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    return (regex.hasMatch(value)) ? true : false;
  }

  Future resetPassword(BuildContext context)async{
      if(isEmailValidation){
        try{
          await auth.sendPasswordResetEmail(email: emailController.text);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Check your email"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ));

          Navigator.of(context).pop(context);
        }on PlatformException catch (e){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.message.toString()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ));
        }
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.purple,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              const Center(
                child: Text(
                  "Reset passwrod",
                  style: TextStyle(
                      color: Colors.purple,
                      fontSize: 36,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
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
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () async{
                      await resetPassword(context);
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 32,
                    height: 48,
                    child: const Center(
                        child: Text(
                          "Reset",
                          style: TextStyle(fontSize: 18),
                        )),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
