import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat/pages/pages.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  FirebaseAuth auth = FirebaseAuth.instance;

  Future signOut() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({
      'token': '',
    });
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Account'),
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasData) {
              UserModel userModel = UserModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(7),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 16),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: userModel.image!.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: userModel.image!,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'assets/images/default_user_image.png',
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                      )),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userModel.userName!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                const SizedBox(height: 4,),
                                GestureDetector(
                                  onTap: (){
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const ChangeInformationPage()));
                                  },
                                  child: const Text(
                                    'Update your information > ',
                                    style: TextStyle(
                                      color: Colors.purple,
                                        fontSize: 14),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      iconColor: Colors.purple,
                      textColor: Colors.purple,
                      leading: const Icon(Icons.lock),
                      title: const Text('Change password'),
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const ChangePasswordPage()));
                      },
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      iconColor: Colors.purple,
                      textColor: Colors.purple,
                      leading: const Icon(Icons.message),
                      title: const Text('Message requests '),
                      onTap: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const MessageRequestsPage()));
                      },
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      iconColor: Colors.red,
                      textColor: Colors.red,
                      leading: const Icon(Icons.lock),
                      title: const Text('Log out'),
                      onTap: ()async{
                        await signOut();
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>const LoginPage()), (route) => false);
                      },
                    )
                  ],
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ));
  }
}
