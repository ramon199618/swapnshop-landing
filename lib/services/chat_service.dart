// import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createOrGetChat({
    required String userA,
    required String userB,
  }) async {
    // TODO: Firebase wieder aktivieren
    // final participants = [userA, userB]..sort();
    // final chatQuery = await _firestore
    //     .collection('chats')
    //     .where('participants', isEqualTo: participants)
    //     .limit(1)
    //     .get();
    // if (chatQuery.docs.isNotEmpty) {
    //   return chatQuery.docs.first.id;
    // }
    // final chatDoc = await _firestore.collection('chats').add({
    //   'participants': participants,
    //   'createdAt': FieldValue.serverTimestamp(),
    //   'lastMessage': '',
    //   'lastMessageTime': FieldValue.serverTimestamp(),
    // });
    // return chatDoc.id;

    // Dummy-Chat-ID für Entwicklung
    await Future.delayed(const Duration(milliseconds: 300));
    return 'dummy_chat_${DateTime.now().millisecondsSinceEpoch}';
  }

  Stream<dynamic> getChatMessages(String chatId) {
    // TODO: Firebase wieder aktivieren
    // return _firestore
    //     .collection('chats')
    //     .doc(chatId)
    //     .collection('messages')
    //     .orderBy('timestamp', descending: true)
    //     .snapshots();

    // Dummy-Stream für Entwicklung
    return Stream.value(null);
  }

  Future<void> sendMessage(
    String chatId,
    String message,
    String senderId,
  ) async {
    // TODO: Firebase wieder aktivieren
    // await _firestore
    //     .collection('chats')
    //     .doc(chatId)
    //     .collection('messages')
    //     .add({
    //   'text': message,
    //   'senderId': senderId,
    //   'timestamp': FieldValue.serverTimestamp(),
    // });
    // await _firestore.collection('chats').doc(chatId).update({
    //   'lastMessage': message,
    //   'lastMessageTime': FieldValue.serverTimestamp(),
    // });

    // Dummy für Entwicklung
    await Future.delayed(const Duration(milliseconds: 200));
    print('Nachricht würde gesendet: $message');
  }
}

// TODO: ChatService für später implementieren
