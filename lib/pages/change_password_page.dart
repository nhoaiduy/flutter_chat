import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat/pages/pages.dart';
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {

  final TextEditingController newPWController = TextEditingController();
  final TextEditingController confirmPWController = TextEditingController();

  bool showNewPW = false;
  bool showConfirmPW = false;

  bool isNewValidation = true;
  bool isConfirmPWValidation = true;

  Future savePassword()async{
    if(isNewValidation && isConfirmPWValidation){
      if(newPWController.text == confirmPWController.text){
        try {
          await FirebaseAuth.instance.currentUser!.updatePassword(newPWController.text);
        } on FirebaseAuthException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.message.toString()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ));
          print(e.message);
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

  Future signOut() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'token': '',
    });
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Change password'),
        actions: [
          TextButton(onPressed: ()async{
            await savePassword();
            await signOut();
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=> const LoginPage()), (route) => false);
          }, child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 18),))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: newPWController,
              obscureText: !showNewPW,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  errorText:
                  !isNewValidation ? "Please enter a password!" : null,
                  suffixIcon: InkWell(
                    onTap: () {
                      setState(() {
                        showNewPW = !showNewPW;
                      });
                    },
                    child: !showNewPW
                        ? const Icon(Icons.visibility)
                        : const Icon(Icons.visibility_off),
                  )),
              onChanged: (text) {
                setState(() {
                  if (newPWController.text.length < 6) {
                    isNewValidation = false;
                  } else {
                    isNewValidation = true;
                  }
                });
              },
              onTap: () {
                setState(() {
                  if (newPWController.text.length < 6) {
                    isNewValidation = false;
                  }
                });
              },
            ),
            const SizedBox(height: 12,),
            TextField(
              controller: confirmPWController,
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
                  if (confirmPWController.text.length < 6) {
                    isConfirmPWValidation = false;
                  } else {
                    isConfirmPWValidation = true;
                  }
                });
              },
              onTap: () {
                setState(() {
                  if (confirmPWController.text.length < 6) {
                    isConfirmPWValidation = false;
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
