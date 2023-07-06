import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel{
  String? mesID;
  String? mesDes;
  String? senderID;
  Timestamp? time;

  MessageModel({
    required this.mesID, required this.mesDes, required this.senderID, required this.time
});

  MessageModel.fromJson(Map<String, dynamic> json){
    mesID = json['mesID'];
    mesDes = json['mesDes'];
    senderID = json['senderID'];
    time = json['time'];
  }

  Map<String, dynamic> toJson(){
    return {
      'mesID': mesDes,
      'mesDes': mesDes,
      'senderID': senderID,
      'time': time
    };
  }
}