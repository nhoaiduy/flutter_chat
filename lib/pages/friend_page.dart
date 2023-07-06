import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/models/models.dart';
import 'package:chat/notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat/pages/pages.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({Key? key}) : super(key: key);

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {

  Future confirmAddFriendRequest(String uid) async{
    Map<String, dynamic>? myData  = await getUserData(FirebaseAuth.instance.currentUser!.uid);
    CollectionReference friends = FirebaseFirestore.instance.collection('users').doc(uid).collection('friends');
    await  friends.doc(FirebaseAuth.instance.currentUser!.uid).set(myData);
    String title = '${myData!['userName']} confirmed your add-friend request';
    Map<String, dynamic>? friendData  = await getUserData(uid);
    friends = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('friends');
    await  friends.doc(uid).set(friendData);

    await removeFriendRequest(uid);

    SendNotification.sendPushMessage(friendData!['token'],title, 'Let see!');
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async{
    Map<String, dynamic>? userData;
    await FirebaseFirestore.instance.collection('users')
        .doc(uid).get().then((value) async{
      userData = value.data();
    });
    return userData;
  }

  Future removeFriendRequest( String uid) async{
    CollectionReference requests =  FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('requests');
    await  requests.doc(uid).delete();
  }

  Future removeFriend(String uid)async{
    CollectionReference friend =  FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('friends');
    await  friend.doc(uid).delete();

    friend =  FirebaseFirestore.instance.collection('users').doc(uid).collection('friends');
    await  friend.doc(FirebaseAuth.instance.currentUser!.uid).delete();
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

    await  FirebaseFirestore.instance.collection('users').doc(uid)
        .collection('conversations').doc(FirebaseAuth.instance.currentUser!.uid).set(conversation);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Friends',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(18)),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const SearchUserPage()));
                      },
                      splashRadius: 18,
                      padding: const EdgeInsets.all(0),
                      icon: const Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                    ),
                  )),
            ],
            bottom: TabBar(
              tabs: [
                SizedBox(
                  height: 40,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.people),
                        SizedBox(width: 5),
                        Text("Friend List")
                      ]),
                ),
                SizedBox(
                  height: 40,
                  child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
                    Icon(Icons.person_add),
                    SizedBox(width: 5),
                    Text("Friend Request")
                  ]),
                ),
              ],
              labelColor: Colors.purple,
              unselectedLabelColor: Colors.grey,
            ),
          ),
          body: TabBarView(
            children: [
              StreamBuilder<QuerySnapshot>(
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
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Center(
                                                child: Column(
                                                  children: [
                                                    ClipRRect(
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
                                                    const SizedBox(
                                                      height: 8,
                                                    ),
                                                    Text('${snapshot.data!.docs[index].get('userName')}')
                                                  ],
                                                )),
                                            content: SizedBox(
                                              height: 100,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                                  32,
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.email,
                                                        color: Colors.purple,
                                                      ),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      Text(
                                                          friend.email !)
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.phone,
                                                        color: Colors.purple,
                                                      ),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      Text(
                                                          friend.email!)
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      SizedBox(
                                                        width: MediaQuery.of(context).size.width*0.3,
                                                        child: ElevatedButton(
                                                            onPressed: () {
                                                              goToConversation(friend.userID!, context);
                                                            },
                                                            child: const Padding(
                                                              padding: EdgeInsets.all(8.0),
                                                              child: Text(
                                                                'Chat',
                                                                style: TextStyle(fontSize: 16),
                                                              ),
                                                            )),
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery.of(context).size.width*0.3,
                                                        child: ElevatedButton(
                                                            onPressed: () {
                                                              removeFriend(friend.userID!);
                                                              Navigator.pop(context);
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                                primary: Colors.grey.shade200),
                                                            child: const Padding(
                                                              padding: EdgeInsets.all(8.0),
                                                              child: Text(
                                                                'Remove',
                                                                style: TextStyle(fontSize: 16, color: Colors.black),
                                                              ),
                                                            )
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                  });
                            });
                      }else{
                        return const Center(child:   Text('No friend'));
                      }
                    }
                    return const Center(child:   Text('No friend'));
                  }),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid).collection('requests').snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
                    if(snapshot.hasData){
                      if(snapshot.data!.docs.isNotEmpty){
                        return ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              UserModel request = UserModel.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);
                              return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: request.image!.isNotEmpty? CachedNetworkImage(
                                        imageUrl: request.image!,
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
                                      request.userName! ,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  subtitle: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                          onPressed: () {
                                            confirmAddFriendRequest(request.userID!);
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Confirm',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          )),
                                      ElevatedButton(
                                          onPressed: () {
                                            removeFriendRequest(request.userID!);
                                          },
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.grey.shade200),
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Remove',
                                              style: TextStyle(fontSize: 16, color: Colors.black),
                                            ),
                                          )
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Center(
                                                child: Column(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                      BorderRadius.circular(24),
                                                      child: CachedNetworkImage(
                                                        imageUrl: request.image!,
                                                        width: 48,
                                                        height: 48,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 8,
                                                    ),
                                                    Text(request.userName!)
                                                  ],
                                                )),
                                            content: SizedBox(
                                              height: 100,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                                  32,
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.email,
                                                        color: Colors.purple,
                                                      ),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      Text(
                                                          request.email!)
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.phone,
                                                        color: Colors.purple,
                                                      ),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      Text(
                                                          request.email!)
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                  });
                            });
                      }else{
                        return const Center(child:   Text('No friend request'));
                      }
                    }
                    return const Center(child:   Text('No friend request'));
                  })
            ],
          ),
        ),
    );
  }
}


