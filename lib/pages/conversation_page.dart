import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/models/models.dart';
import 'package:chat/pages/pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';


class ConversationPage extends StatefulWidget {
  const ConversationPage({Key? key}) : super(key: key);

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {

  Future removeConversation(String cid)async{
   await  FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('conversations').doc(cid)
       .collection('messages').get().then((value){
      for (var element in value.docs) {
        element.reference.delete();
      }
   });

  await  FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
       .collection('conversations').doc(cid).delete();

  await FirebaseFirestore.instance.collection('users').doc(cid)
        .collection('conversations').doc(FirebaseAuth.instance.currentUser!.uid )
        .collection('messages').get().then((value){
      for (var element in value.docs) {
        element.reference.delete();
      }
    });
   await FirebaseFirestore.instance.collection('users').doc(cid)
       .collection('conversations').doc(FirebaseAuth.instance.currentUser!.uid ).delete();
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async{
    Map<String, dynamic>? userData;
    await FirebaseFirestore.instance.collection('users')
        .doc(uid).get().then((value) async{
      userData = value.data();
    });
    return userData;
  }

  String? image;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Conversations',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18)),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const AddConversationPage()));
                  },
                  splashRadius: 18,
                  padding: const EdgeInsets.all(0),
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.black,
                  ),
                ),
              )),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const SearchConversationPage()));
              },
              child: Container(
                width: width - 16,
                height: 48,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 8,
                    ),
                    Icon(
                      Icons.search,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Search',
                      style: TextStyle(color: Colors.grey.shade700),
                    )
                  ],
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('conversations').orderBy('lastTime', descending: true).snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
                if(snapshot.hasData){
                  if(snapshot.data!.docs.isNotEmpty){
                    return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          ConversationModel conversation = ConversationModel.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);
                          if(conversation.isFriend!){
                            return ListTile(
                              leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: conversation.image!.isNotEmpty? CachedNetworkImage(
                                    imageUrl: conversation.image!,
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                  ):Image.asset(
                                    'assets/images/default_user_image.png',
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                  )
                              ),
                              title: Text(conversation.conName!),
                              subtitle:  conversation.lastMes!.isNotEmpty
                                  ?Text(conversation.lastMes!):null,
                              onTap: () async {
                                Map<String, dynamic>? userData = await getUserData(conversation.cid!);
                                Navigator.of(context).push(MaterialPageRoute(builder: (context)=> ConversationDetailPage(userInfo: userData!)));
                              },
                              onLongPress: (){
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Remove this conversation'),
                                        content: const Text('Are you sure to remove?'),
                                        actions: [
                                          TextButton(
                                              onPressed: (){
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Cancel')
                                          ),
                                          TextButton(
                                              onPressed: (){
                                                removeConversation(conversation.cid!);
                                                Navigator.pop(context);
                                              },
                                              child: const Text('OK')
                                          ),
                                        ],
                                      );
                                    });
                              },
                            );
                          }
                          return const Center();
                        });
                  }
                  return const Center(child: Text('No conversation'),);
                }
                return const Center(child: Text('No conversation'),);
              },
            )
          ],
        ),
      ),
    );
  }
}
