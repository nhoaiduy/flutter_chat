import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/models/models.dart';
import 'package:chat/pages/pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchConversationPage extends StatefulWidget {
  const SearchConversationPage({Key? key}) : super(key: key);

  @override
  State<SearchConversationPage> createState() => _SearchConversationPageState();
}

class _SearchConversationPageState extends State<SearchConversationPage> {

  final TextEditingController _searchConversationController = TextEditingController();
  String searchString ='';

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
          stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('conversations').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
            if(snapshot.hasData){
              return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                   ConversationModel conversationModel = ConversationModel.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);
                    if(conversationModel.conName!.toLowerCase().contains(searchString.toLowerCase())){
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: conversationModel.image!.isNotEmpty? CachedNetworkImage(
                              imageUrl: conversationModel.image!,
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
                        title: Text(conversationModel.conName!),
                        onTap: () async{
                          Map<String, dynamic>? userData = await getUserData(conversationModel.cid!);
                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ConversationDetailPage(userInfo: userData!)));
                        },
                      );
                    }
                    return const Center();
                  });
            }
            return const Center(child: Text('No found user'),);
          },
        )
    );
  }
}
