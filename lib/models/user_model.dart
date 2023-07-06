import 'models.dart';

class UserModel {
  String? userID;
  String? userName;
  String? email;
  String? image;
  String? token;
  List<UserModel>? friends;
  List<UserModel>? requests;
  List<ConversationModel>? conversations;

  UserModel(
      {required this.userID,
      required this.userName,
      required this.email,
      this.image,
      this.token,
      this.requests,
      this.friends,
      this.conversations}) {
    image = image ?? "";
    token = token ?? "";
    requests = requests??[];
    friends = friends??[];
    conversations = conversations??[];
  }

  UserModel.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    userName = json['userName'];
    email = json['email'];
    image = json['image']??'';
    token = json['token']??'';
    requests = json['requests']??[];
    friends = json['friends']??[];
    conversations = json['conversations']??[];
  }

  Map<String, dynamic> toJson(){
    return {
      'userID': userID,
      'userName':userName,
      'email': email,
      'image': image,
      'token': token,
      'requests': requests,
      'friends': friends,
      'conversations': conversations,
    };
  }
}
