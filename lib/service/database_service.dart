import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import '/main.dart';
import '/models/chat.dart';

import '/models/message.dart';
import '/models/profile.dart';
import 'auth_service.dart';

class DatabaseService {
  final _firestore = FirebaseFirestore.instance;

  late CollectionReference _userCollection;
  late CollectionReference _chatCollection;
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;

  DatabaseService() {
    _authService = _getIt.get<AuthService>();
    _userCollection = _firestore.collection("users").withConverter<Profile>(
        fromFirestore: (snapshots, _) => Profile.fromJson(
              snapshots.data()!,
            ),
        toFirestore: (user_profile, _) => user_profile.toJson());

    _chatCollection = _firestore.collection("chats").withConverter<Chat>(
        fromFirestore: (snapshots, _) => Chat.fromJson(
              snapshots.data()!,
            ),
        toFirestore: (chat, _) => chat.toJson());
  }
  // withConverter<Todo>: This method attaches a converter to the collection reference. This converter handles
  //  the conversion between Firestore documents and Todo objects for snapshots and add only.
  // With this setup, whenever you interact with _todosRef,Firestore automatically uses these converters to
  // handle the data conversion.Like before toFirestore is called
// if data is going to be sent and fromfirestore is called before receiving fro firestore.

  Stream<QuerySnapshot<Profile>> getUserProfiles() {
    return _userCollection
        .where("userid", isNotEqualTo: _authService.user!.uid)
        .snapshots() as Stream<QuerySnapshot<Profile>>;
  }
  // snapshots(): This method listens to real-time updates in the todos collection.
  // Whenever a document is added, modified, or deleted, a new QuerySnapshot is emitted.
  // Conversion: Each QuerySnapshot contains a list of documents, and these documents are automatically converted
  // to Todo objects using the fromFirestore converter defined in the constructor.

  void addprofile(Profile user_profile) async {
    _userCollection.add(user_profile);
  }

  Future<void> createUserProfile({required Profile user_profile}) async {
    await _userCollection.doc(user_profile.userid).set(user_profile);
  }

  Future<void> updateprofile(
      String user_profileId, Profile user_profile) async {
    await _userCollection.doc(user_profileId).update(user_profile.toJson());
  }

  // Why toJson() is called?
  // The .update() method doesn't use the toFirestore converter automatically. It expects a raw map of data to apply '
  // the update. Therefore, you need to manually call toJson() to convert the Todo object into a JSON map
  void deleteprofile(String user_profileId) {
    _userCollection.doc(user_profileId).delete();
  }

  Future<Profile?> fetchPersonalProfile() async {
    // Perform a query to get the document where userid is equal to the current user's uid
    QuerySnapshot querySnapshot = await _userCollection
        .where('userid', isEqualTo: _authService.user!.uid)
        .get();

    // Cast the querySnapshot to QuerySnapshot<Profile>
    QuerySnapshot<Profile> profileSnapshot =
        querySnapshot as QuerySnapshot<Profile>;

    // Check if the query returned any documents
    if (profileSnapshot.docs.isNotEmpty) {
      // Assuming there's only one document matching the query
      DocumentSnapshot<Profile> docSnapshot = profileSnapshot.docs.first;
      return docSnapshot.data();
    } else {
      return null;
    }
  }

  Future<bool> checkChatExists(String uid1, String uid2) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final result = await _chatCollection.doc(chatID).get();
    if (result != null) {
      return result.exists;
    }
    return false;
  }

  Future<void> createNewChat(String uid1, String uid2) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);

    final docRef = _chatCollection.doc(chatID);
    final chat = Chat(
      id: chatID,
      participants: [uid1, uid2],
      messages: [],
    );

    await docRef.set(chat);
  }

  Future<void> sendChatMessage(
      String uid1, String uid2, Message message) async {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    final docRef = _chatCollection.doc(chatID);

    await docRef.update({
      "messages": FieldValue.arrayUnion([
        message.toJson(),
      ]),
    });
  }

  Stream<DocumentSnapshot<Chat>> getChatData(String uid1, String uid2) {
    String chatID = generateChatID(uid1: uid1, uid2: uid2);
    return _chatCollection.doc(chatID).snapshots()
        as Stream<DocumentSnapshot<Chat>>;
  }
}
