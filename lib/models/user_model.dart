// ignore_for_file: non_constant_identifier_names

import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserObject extends HiveObject {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String? email;

  @HiveField(2)
  final String? profile_picture;

  @HiveField(3)
  final String? first_name;

  @HiveField(4)
  final String? last_name;

  @HiveField(5)
  final String? full_name;

  @HiveField(6)
  final String? username;

  @HiveField(7)
  final List<String> friends;

  @HiveField(8)
  final List<String> pinnedBets;

  @HiveField(9)
  final double total_money_won;

  @HiveField(10)
  final int total_bets;

  @HiveField(11)
  final String? username_lowercase;

  @HiveField(12)
  final List<Map<String, dynamic>> friend_requests;

  @HiveField(13)
  final List<Map<String, dynamic>> sent_friend_requests;

  @HiveField(14)
  final Map<String, String> bets;

  UserObject({
    required this.uid,
    this.email,
    this.profile_picture,
    this.first_name,
    this.last_name,
    this.full_name,
    this.username,
    required this.friends,
    required this.pinnedBets,
    required this.total_money_won,
    required this.total_bets,
    this.username_lowercase,
    required this.friend_requests,
    required this.sent_friend_requests,
    required this.bets
  });

  UserObject copyWith({
    List<Map<String, dynamic>>? friend_requests,
    List<Map<String, dynamic>>? sent_friend_requests,
    List<String>? friends,
    double? total_money_won,
    int? total_bets,
    Map<String, String>? bets,
    String? profile_picture,
  }) {
    return UserObject(
      uid: uid,
      email: email,
      profile_picture: profile_picture ?? this.profile_picture,
      first_name: first_name,
      last_name: last_name,
      full_name: full_name,
      username: username,
      username_lowercase: username_lowercase,
      pinnedBets: pinnedBets,
      friends: friends ?? this.friends,
      total_money_won: total_money_won ?? this.total_money_won,
      total_bets: total_bets ?? this.total_bets,
      friend_requests: friend_requests ?? this.friend_requests,
      sent_friend_requests: sent_friend_requests ?? this.sent_friend_requests,
      bets: bets ?? this.bets,
    );
  }

  factory UserObject.fromMap(String uid, Map<String, dynamic> data) {
    return UserObject(
      uid: uid,
      email: data['email'],
      profile_picture: data['profile_picture'],
      first_name: data['first_name'],
      last_name: data['last_name'],
      full_name: data['full_name'],
      username: data['username'],
      friends: List<String>.from(data['friends'] ?? []),
      pinnedBets: List<String>.from(data['pinned_bets'] ?? []),
      total_money_won: data['totalMoneyWon']?.toDouble() ?? 0.0,
      total_bets: data['totalBets'] ?? 0,
      username_lowercase: data['username_lowercase'],
      friend_requests: List<Map<String, dynamic>>.from(data['friend_requests'] ?? []),
      sent_friend_requests: List<Map<String, dynamic>>.from(data['sent_friend_requests'] ?? []),
      bets: Map<String, String>.from(data['bets'] ?? {}),
    );
  }
}
