import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/models/models.dart';
import 'package:chat/notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'pages.dart';

class SearchUserPage extends StatefulWidget {
  const SearchUserPage({Key? key}) : super(key: key);

  @override
  State<SearchUserPage> createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {

  final TextEditingController _searchUserController = TextEditingController();
  String searchString ='';

  Future addFriendRequest( String uid) async{
    CollectionReference requests = FirebaseFirestore.instance.collection('users').doc(uid).collection('requests');
    Map<String, dynamic>? map  = await getUserData(FirebaseAuth.instance.currentUser!.uid);
    await  requests.doc(FirebaseAuth.instance.currentUser!.uid).set(map);
    String title = '${map!['userName']} a add-friend request';

    map = await getUserData(uid);
    SendNotification.sendPushMessage(map!['token'], title, "");
  }

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
    conversation['isFriend'] = false;

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
              controller: _searchUserController,
              style: const TextStyle(fontSize: 16),
              decoration:  const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                hintText: "Enter user name",
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
          stream: FirebaseFirestore.instance
                .collection('users').where('userID', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
            if(snapshot.hasData){
              return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    UserModel userModel = UserModel.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);
                    if(userModel.userName!.toLowerCase().contains(searchString.toLowerCase())){
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: userModel.image!.isNotEmpty? CachedNetworkImage(
                              imageUrl: userModel.image!,
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
                        title: Text(userModel.userName!),
                        onTap: (){
                          showDialog(
                              context: context,
                              builder: (context){
                                return AlertDialog(
                                  title: Center(
                                      child: Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(24),
                                            child: userModel.image!.isNotEmpty? CachedNetworkImage(
                                              imageUrl: userModel.image!,
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
                                          const SizedBox(
                                            height: 8,
                                          ),
                                          Text(userModel.userName!)
                                        ],
                                      )),
                                  content: SizedBox(
                                    height: 150,
                                    width: MediaQuery.of(context).size.width-32,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.email, color: Colors.purple,),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                                userModel.email!)
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.phone, color: Colors.purple,),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                                userModel.email!)
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context).size.width*0.3,
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    addFriendRequest(userModel.userID!);
                                                  },
                                                  child: const Text('Add friend')
                                              ),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context).size.width*0.3,
                                              child: ElevatedButton(
                                                  onPressed: ()async {
                                                    await goToConversation(userModel.userID!, context);
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                      primary: Colors.grey.shade200),
                                                  child: Text(
                                                    'Send mess',
                                                    style: TextStyle(
                                                        color:
                                                        Colors.grey.shade600),
                                                  )
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                      );
                    }
                    else{
                      return const Center();
                    }
                  });
            }
            return const Center(child: Text('No found user'),);
          },
        )
    );
  }
}
