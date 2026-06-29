// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drive_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DriveSessionAdapter extends TypeAdapter<DriveSession> {
  @override
  final int typeId = 0;

  @override
  DriveSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DriveSession(
      startTime: fields[0] as DateTime,
      endTime: fields[1] as DateTime,
      finalScore: fields[2] as int,
      distanceKm: fields[3] as double,
      events: (fields[4] as List).cast<DriveEvent>(),
    );
  }

  @override
  void write(BinaryWriter writer, DriveSession obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.startTime)
      ..writeByte(1)
      ..write(obj.endTime)
      ..writeByte(2)
      ..write(obj.finalScore)
      ..writeByte(3)
      ..write(obj.distanceKm)
      ..writeByte(4)
      ..write(obj.events);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriveSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DriveEventAdapter extends TypeAdapter<DriveEvent> {
  @override
  final int typeId = 1;

  @override
  DriveEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DriveEvent(
      type: fields[0] as String,
      pointsDeducted: fields[1] as int,
      timestamp: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DriveEvent obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.pointsDeducted)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriveEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
