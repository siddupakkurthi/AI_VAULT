// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medical_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicalProfileAdapter extends TypeAdapter<MedicalProfile> {
  @override
  final int typeId = 0;

  @override
  MedicalProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicalProfile(
      id: fields[0] as String,
      fullName: fields[1] as String,
      age: fields[2] as int,
      gender: fields[3] as String,
      bloodGroup: fields[4] as String,
      height: fields[5] as double,
      weight: fields[6] as double,
      emergencyContactName: fields[7] as String,
      emergencyPhone: fields[8] as String,
      relationship: fields[9] as String,
      allergies: (fields[10] as List).cast<String>(),
      diseases: (fields[11] as List).cast<String>(),
      medications: (fields[12] as List).cast<String>(),
      isOrganDonor: fields[13] as bool,
      medicalNotes: fields[14] as String,
      aiSummary: fields[15] as String,
      qrId: fields[16] as String,
      profileImagePath: fields[17] as String?,
      createdAt: fields[18] as DateTime,
      updatedAt: fields[19] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MedicalProfile obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.age)
      ..writeByte(3)
      ..write(obj.gender)
      ..writeByte(4)
      ..write(obj.bloodGroup)
      ..writeByte(5)
      ..write(obj.height)
      ..writeByte(6)
      ..write(obj.weight)
      ..writeByte(7)
      ..write(obj.emergencyContactName)
      ..writeByte(8)
      ..write(obj.emergencyPhone)
      ..writeByte(9)
      ..write(obj.relationship)
      ..writeByte(10)
      ..write(obj.allergies)
      ..writeByte(11)
      ..write(obj.diseases)
      ..writeByte(12)
      ..write(obj.medications)
      ..writeByte(13)
      ..write(obj.isOrganDonor)
      ..writeByte(14)
      ..write(obj.medicalNotes)
      ..writeByte(15)
      ..write(obj.aiSummary)
      ..writeByte(16)
      ..write(obj.qrId)
      ..writeByte(17)
      ..write(obj.profileImagePath)
      ..writeByte(18)
      ..write(obj.createdAt)
      ..writeByte(19)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
