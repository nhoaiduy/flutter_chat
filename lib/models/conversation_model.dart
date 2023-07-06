import 'package:cloud_firestore/cloud_firestore.dart';

import 'models.dart';

class ConversationModel {
  String? cid;
  String? conName;
  String? image;
  bool? isFriend;
  String? lastMes;
  Timestamp? lastTime;
  List<MessageModel>? messages;

  ConversationModel(
      {required this.cid,
      required this.conName,
      this.image,
      required this.isFriend,
      this.lastMes,
      required this.lastTime,
      this.messages
      }){
    messages = messages??[];
  }

  ConversationModel.fromJson(Map<String, dynamic> json){
    cid = json['cid'];
    conName = json['conName'];
    image = json['image'];
    isFriend = json['isFriend'];
    lastMes = json['lastMes'];
    lastTime = json['lastTime'];
    messages = json['messages']??[];
  }

  Map<String, dynamic> toJson(){
    return {
    'cid': cid,
    'conName': conName,
    'image': image,
    'isFriend': isFriend,
    'lastMes': lastMes,
    'lastTime': lastTime,
    'messages': messages,
    };
  }


}
