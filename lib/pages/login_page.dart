import 'package:chat/pages/pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  FirebaseAuth auth= FirebaseAuth.instance;

  bool show = false;
  bool isEmailValidation = true;
  bool isPWValidation = true;

  bool validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    return (regex.hasMatch(value)) ? true : false;
  }

  Future<void> signIn(String email, String pw) async {
    if (isPWValidation && isEmailValidation) {
      try {
        await auth
            .signInWithEmailAndPassword(email: email, password: pw)
            .then((value) {

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Sign in successfully"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ));

          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) =>
                  const NavigationPage()),
                  (route) => false);

        });
      } on FirebaseAuthException catch (e) {
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
      appBar: const PreferredSize(preferredSize: Size(0,0), child: Text('')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome, ",
              style: TextStyle(
                  color: Colors.purple,
                  fontSize: 36,
                  fontWeight: FontWeight.bold),
            ),
            const Text(
              "Sign in to continue",
              style: TextStyle(
                  color: Colors.purple,
                  fontSize: 36,
                  fontWeight: FontWeight.bold),
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
              height: 16,
            ),
            TextField(
              controller: pwController,
              obscureText: !show,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  errorText:
                  !isPWValidation ? "Please enter a password!" : null,
                  suffixIcon: InkWell(
                    onTap: () {
                      setState(() {
                        show = !show;
                      });
                    },
                    child: !show
                        ? const Icon(Icons.visibility)
                        : const Icon(Icons.visibility_off),
                  )),
              onChanged: (text) {
                setState(() {
                  if (pwController.text.isEmpty) {
                    isPWValidation = false;
                  } else {
                    isPWValidation = true;
                  }
                });
              },
              onTap: () {
                setState(() {
                  if (pwController.text.isEmpty) {
                    isPWValidation = false;
                  }
                });
              },
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const ResetPassword()));
                    },
                    child: const Text(
                      "Forgot your password?",
                      style: TextStyle(color: Colors.purple),
                    ))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  signIn(emailController.text, pwController.text);
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 32,
                  height: 48,
                  child: const Center(
                      child: Text(
                        "Sign In",
                        style: TextStyle(fontSize: 18),
                      )),
                )),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Create your account? "),
                      GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const RegisterPage()));
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(color: Colors.purple),
                          ))
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }
}
