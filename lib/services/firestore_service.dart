// import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing.dart';
import '../models/match.dart';

class FirestoreService {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addListing(Listing listing) async {
    // TODO: Firebase wieder aktivieren
    // await _firestore.collection('listings').add(listing.toJson());
    await Future.delayed(const Duration(milliseconds: 500));
    print('Listing würde gespeichert: ${listing.title}');
  }

  Stream<List<Listing>> getListings() {
    // TODO: Firebase wieder aktivieren
    // return _firestore
    //     .collection('listings')
    //     .snapshots()
    //     .map(
    //       (snapshot) =>
    //           snapshot.docs.map((doc) => Listing.fromJson(doc.data())).toList(),
    //     );
    return Stream.value([]);
  }

  Future<void> addMatch(MatchModel match) async {
    // TODO: Firebase wieder aktivieren
    // await _firestore.collection('matches').add(match.toJson());
    await Future.delayed(const Duration(milliseconds: 300));
    print('Match würde gespeichert');
  }

  Stream<List<MatchModel>> getMatchesForUser(String userId) {
    // TODO: Firebase wieder aktivieren
    // return _firestore
    //     .collection('matches')
    //     .where('isActive', isEqualTo: true)
    //     .where('participants', arrayContains: userId)
    //     .snapshots()
    //     .map(
    //       (snapshot) => snapshot.docs
    //           .map((doc) => MatchModel.fromJson(doc.id, doc.data()))
    //           .toList(),
    //     );
    return Stream.value([]);
  }
}
