import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages.dart';
import 'package:flutter/material.dart';

class MessageRequestsPage extends StatefulWidget {
  const MessageRequestsPage({Key? key}) : super(key: key);

  @override
  State<MessageRequestsPage> createState() => _MessageRequestsPageState();
}

class _MessageRequestsPageState extends State<MessageRequestsPage> {

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.purple,
        ),
        titleTextStyle: const TextStyle(color: Colors.purple, fontSize: 18, fontWeight: FontWeight.bold),
        title: const Text('Message requests'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('conversations').orderBy('lastTime', descending: true).snapshots() ,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
            if(snapshot.hasData){
              if(snapshot.data!.docs.isNotEmpty){
                return ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      ConversationModel conversationModel = ConversationModel.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);

                      if(!conversationModel.isFriend!){
                        return ListTile(
                          leading: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: conversationModel.image!.isNotEmpty? CachedNetworkImage(
                                imageUrl: conversationModel.image!,
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
                          title: Text(conversationModel.conName!),
                          subtitle:  conversationModel.lastMes!.isNotEmpty
                              ?Text(conversationModel.lastMes!):null,
                          onTap: () async {
                            Map<String, dynamic>? userData = await getUserData(conversationModel.cid!);
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
                                            removeConversation(conversationModel.cid!);
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
        ),
      ),
    );
  }
}