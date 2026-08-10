import 'package:hive/hive.dart';

part 'medical_profile.g.dart';

@HiveType(typeId: 0)
class MedicalProfile extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String fullName;

  @HiveField(2)
  int age;

  @HiveField(3)
  String gender;

  @HiveField(4)
  String bloodGroup;

  @HiveField(5)
  double height;

  @HiveField(6)
  double weight;

  @HiveField(7)
  String emergencyContactName;

  @HiveField(8)
  String emergencyPhone;

  @HiveField(9)
  String relationship;

  @HiveField(10)
  List<String> allergies;

  @HiveField(11)
  List<String> diseases;

  @HiveField(12)
  List<String> medications;

  @HiveField(13)
  bool isOrganDonor;

  @HiveField(14)
  String medicalNotes;

  @HiveField(15)
  String aiSummary;

  @HiveField(16)
  String qrId;

  @HiveField(17)
  String? profileImagePath;

  @HiveField(18)
  DateTime createdAt;

  @HiveField(19)
  DateTime updatedAt;

  @HiveField(20)
  String userPhone;

  MedicalProfile({
    required this.id,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.height,
    required this.weight,
    required this.emergencyContactName,
    required this.emergencyPhone,
    required this.relationship,
    required this.allergies,
    required this.diseases,
    required this.medications,
    required this.isOrganDonor,
    required this.medicalNotes,
    required this.aiSummary,
    required this.qrId,
    this.profileImagePath,
    required this.createdAt,
    required this.updatedAt,
    this.userPhone = '',
  });

  MedicalProfile copyWith({
    String? id,
    String? fullName,
    int? age,
    String? gender,
    String? bloodGroup,
    double? height,
    double? weight,
    String? emergencyContactName,
    String? emergencyPhone,
    String? relationship,
    List<String>? allergies,
    List<String>? diseases,
    List<String>? medications,
    bool? isOrganDonor,
    String? medicalNotes,
    String? aiSummary,
    String? qrId,
    String? profileImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userPhone,
  }) {
    return MedicalProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      relationship: relationship ?? this.relationship,
      allergies: allergies ?? this.allergies,
      diseases: diseases ?? this.diseases,
      medications: medications ?? this.medications,
      isOrganDonor: isOrganDonor ?? this.isOrganDonor,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      aiSummary: aiSummary ?? this.aiSummary,
      qrId: qrId ?? this.qrId,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userPhone: userPhone ?? this.userPhone,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'userPhone': userPhone,
    'age': age,
    'gender': gender,
    'bloodGroup': bloodGroup,
    'height': height,
    'weight': weight,
    'emergencyContactName': emergencyContactName,
    'emergencyPhone': emergencyPhone,
    'relationship': relationship,
    'allergies': allergies,
    'diseases': diseases,
    'medications': medications,
    'isOrganDonor': isOrganDonor,
    'medicalNotes': medicalNotes,
    'aiSummary': aiSummary,
    'qrId': qrId,
    'profileImagePath': profileImagePath,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory MedicalProfile.fromJson(Map<String, dynamic> json) => MedicalProfile(
    id: json['id'] ?? '',
    fullName: json['fullName'] ?? '',
    userPhone: json['userPhone'] ?? json['phone'] ?? '',
    age: json['age'] ?? 0,
    gender: json['gender'] ?? '',
    bloodGroup: json['bloodGroup'] ?? '',
    height: (json['height'] ?? 0.0).toDouble(),
    weight: (json['weight'] ?? 0.0).toDouble(),
    emergencyContactName: json['emergencyContactName'] ?? '',
    emergencyPhone: json['emergencyPhone'] ?? '',
    relationship: json['relationship'] ?? '',
    allergies: (json['allergies'] as List?)?.map((e) => e.toString()).toList() ?? [],
    diseases: (json['diseases'] as List?)?.map((e) => e.toString()).toList() ?? [],
    medications: (json['medications'] as List?)?.map((e) => e.toString()).toList() ?? [],
    isOrganDonor: json['isOrganDonor'] ?? false,
    medicalNotes: json['medicalNotes'] ?? '',
    aiSummary: json['aiSummary'] ?? '',
    qrId: json['qrId'] ?? '',
    profileImagePath: json['profileImagePath'],
    createdAt: _parseDateTime(json['createdAt']),
    updatedAt: _parseDateTime(json['updatedAt']),
  );

  static DateTime _parseDateTime(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is DateTime) return val;
    if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    try {
      // Handles cloud_firestore Timestamp via dynamic invocation
      return (val as dynamic).toDate() as DateTime;
    } catch (_) {
      return DateTime.now();
    }
  }

  double get completionPercentage {
    int total = 14;
    int filled = 0;
    if (fullName.isNotEmpty) filled++;
    if (age > 0) filled++;
    if (gender.isNotEmpty) filled++;
    if (bloodGroup.isNotEmpty) filled++;
    if (height > 0) filled++;
    if (weight > 0) filled++;
    if (emergencyContactName.isNotEmpty) filled++;
    if (emergencyPhone.isNotEmpty) filled++;
    if (relationship.isNotEmpty) filled++;
    if (allergies.isNotEmpty) filled++;
    if (diseases.isNotEmpty) filled++;
    if (medications.isNotEmpty) filled++;
    if (medicalNotes.isNotEmpty) filled++;
    if (profileImagePath != null && profileImagePath!.isNotEmpty) filled++;
    return filled / total;
  }

  double get bmi {
    if (height <= 0 || weight <= 0) return 0;
    double hMeters = height / 100;
    return weight / (hMeters * hMeters);
  }

  String get bmiCategory {
    double b = bmi;
    if (b == 0) return 'N/A';
    if (b < 18.5) return 'Underweight';
    if (b < 25) return 'Normal';
    if (b < 30) return 'Overweight';
    return 'Obese';
  }
}
