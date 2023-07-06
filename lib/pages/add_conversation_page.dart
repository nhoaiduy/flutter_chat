import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/models/models.dart';
import 'package:chat/pages/pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AddConversationPage extends StatefulWidget {
  const AddConversationPage({Key? key}) : super(key: key);

  @override
  State<AddConversationPage> createState() => _AddConversationPageState();
}

class _AddConversationPageState extends State<AddConversationPage> {

  Future goToConversation(String uid, BuildContext context)async{
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('conversations').doc(uid).get().then((value) async{
      if(!value.exists){
        await createNewConversation(uid);
      }
    });

    Map<String, dynamic>? userData = await getUserData(uid);
    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ConversationDetailPage(userInfo: userData!)));
  }

  Future createNewConversation(String uid) async{
    String mesDes = '';
    Map<String, dynamic>? myData  = await getUserData(FirebaseAuth.instance.currentUser!.uid);
    Map<String, dynamic>? friendData  = await getUserData(uid);
    Map<String, dynamic>? conversation = {
      'cid': uid,
      'conName' : friendData!['userName'],
      'image': friendData['image'],
      'lastTime': Timestamp.now(),
      'lastMes': mesDes,
      'isFriend': true,
    };

    await  FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('conversations').doc(uid).set(conversation);

    conversation['conName'] = myData!['userName'];
    conversation['cid'] = myData['userID'];
    conversation['image'] = myData['image'];

    await  FirebaseFirestore.instance.collection('users').doc(uid)
        .collection('conversations').doc(FirebaseAuth.instance.currentUser!.uid).set(conversation);
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async{
    Map<String, dynamic>? userData;
    await FirebaseFirestore.instance.collection('users')
        .doc(uid).get().then((value) async{
      userData = value.data();
    });
    return userData;
  }

  final TextEditingController _searchConversationController = TextEditingController();
  String searchString ='';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: TextField(
            controller: _searchConversationController,
            style: const TextStyle(fontSize: 16),
            decoration:  const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              hintText: "Enter conversation name",
              border: InputBorder.none,
            ),
            onChanged: (text){
              setState((){
                searchString = text;
              });
            },
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid).collection('friends').orderBy('userName').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
            if(snapshot.hasData){
              if(snapshot.data!.docs.isNotEmpty){
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      UserModel friend = UserModel.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);
                      if(friend.userName!.toLowerCase().contains(searchString.toLowerCase())){
                        return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            leading: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: friend.image!.isNotEmpty? CachedNetworkImage(
                                  imageUrl: friend.image!,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                ):Image.asset(
                                  'assets/images/default_user_image.png',
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                )
                            ),
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                friend.userName!,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                            onTap: () {
                              goToConversation(friend.userID!, context);
                            });
                      }
                      return const Center();
                    });
              }else{
                return const Center(child:   Text('No friend'));
              }
            }
            return const Center(child:   Text('No friend'));
          }),
    );
  }
}
