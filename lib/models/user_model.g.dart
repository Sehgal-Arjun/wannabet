// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserObjectAdapter extends TypeAdapter<UserObject> {
  @override
  final int typeId = 0;

  @override
  UserObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserObject(
      uid: fields[0] as String,
      email: fields[1] as String?,
      profile_picture: fields[2] as String?,
      first_name: fields[3] as String?,
      last_name: fields[4] as String?,
      full_name: fields[5] as String?,
      username: fields[6] as String?,
      friends: (fields[7] as List).cast<String>(),
      pinnedBets: (fields[8] as List).cast<String>(),
      total_money_won: fields[9] as double,
      total_bets: fields[10] as int,
      username_lowercase: fields[11] as String?,
      friend_requests: (fields[12] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      sent_friend_requests: (fields[13] as List)
          .map((dynamic e) => (e as Map).cast<String, dynamic>())
          .toList(),
      bets: (fields[14] as Map).cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserObject obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.profile_picture)
      ..writeByte(3)
      ..write(obj.first_name)
      ..writeByte(4)
      ..write(obj.last_name)
      ..writeByte(5)
      ..write(obj.full_name)
      ..writeByte(6)
      ..write(obj.username)
      ..writeByte(7)
      ..write(obj.friends)
      ..writeByte(8)
      ..write(obj.pinnedBets)
      ..writeByte(9)
      ..write(obj.total_money_won)
      ..writeByte(10)
      ..write(obj.total_bets)
      ..writeByte(11)
      ..write(obj.username_lowercase)
      ..writeByte(12)
      ..write(obj.friend_requests)
      ..writeByte(13)
      ..write(obj.sent_friend_requests)
      ..writeByte(14)
      ..write(obj.bets);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
