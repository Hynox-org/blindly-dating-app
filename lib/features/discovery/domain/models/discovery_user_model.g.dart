// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discovery_user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiscoveryUserAdapter extends TypeAdapter<DiscoveryUser> {
  @override
  final int typeId = 0;

  @override
  DiscoveryUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiscoveryUser(
      profileId: fields[0] as String,
      displayName: fields[1] as String,
      age: fields[2] as int,
      bio: fields[3] as String,
      gender: fields[4] as String,
      city: fields[5] as String,
      distanceMeters: fields[6] as double,
      matchScore: fields[7] as int,
      sharedInterestsCount: fields[8] as int,
      sharedLifestyleCount: fields[9] as int,
      mediaUrl: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DiscoveryUser obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.profileId)
      ..writeByte(1)
      ..write(obj.displayName)
      ..writeByte(2)
      ..write(obj.age)
      ..writeByte(3)
      ..write(obj.bio)
      ..writeByte(4)
      ..write(obj.gender)
      ..writeByte(5)
      ..write(obj.city)
      ..writeByte(6)
      ..write(obj.distanceMeters)
      ..writeByte(7)
      ..write(obj.matchScore)
      ..writeByte(8)
      ..write(obj.sharedInterestsCount)
      ..writeByte(9)
      ..write(obj.sharedLifestyleCount)
      ..writeByte(10)
      ..write(obj.mediaUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscoveryUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
