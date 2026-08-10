import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../models/medical_profile.dart';

class SosService {
  /// Directly calls the emergency contact phone number using system dialer.
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) return false;

    final Uri url = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Fallback launch
        return await launchUrl(url);
      }
    } catch (e) {
      debugPrint('Error launching phone dialer: $e');
      return false;
    }
  }

  /// Opens system SMS app with a pre-filled emergency alert message.
  static Future<bool> sendEmergencySms(MedicalProfile profile) async {
    final cleanPhone = profile.emergencyPhone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) return false;

    final message = '''
🚨 EMERGENCY SOS ALERT 🚨
I need immediate medical assistance!

👤 Name: ${profile.fullName}
🩸 Blood Group: ${profile.bloodGroup}
⚠️ Allergies: ${profile.allergies.isEmpty ? 'None' : profile.allergies.join(', ')}
🏥 Emergency ID: ${profile.qrId}
📞 Contact: ${profile.emergencyContactName} (${profile.relationship})

Sent via AI Life Vault Emergency System.
''';

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: cleanPhone,
      queryParameters: <String, String>{
        'body': message,
      },
    );

    try {
      if (await canLaunchUrl(smsUri)) {
        return await launchUrl(smsUri, mode: LaunchMode.externalApplication);
      } else {
        return await launchUrl(smsUri);
      }
    } catch (e) {
      debugPrint('Error launching SMS: $e');
      return false;
    }
  }

  /// Shares formatted emergency alert card via system share sheet (WhatsApp, Messages, etc.).
  static Future<void> shareEmergencyAlert(MedicalProfile profile) async {
    final alertText = '''
🆘 EMERGENCY MEDICAL ID CARD 🆘
AI LIFE VAULT — Universal Medical Profile

👤 Patient: ${profile.fullName} (${profile.age} yrs, ${profile.gender})
🩸 Blood Group: ${profile.bloodGroup}
⚠️ Critical Allergies: ${profile.allergies.isEmpty ? 'None' : profile.allergies.join(', ')}
🏥 Existing Conditions: ${profile.diseases.isEmpty ? 'None' : profile.diseases.join(', ')}
💊 Current Medications: ${profile.medications.isEmpty ? 'None' : profile.medications.join(', ')}
💚 Organ Donor: ${profile.isOrganDonor ? 'YES' : 'NO'}

📞 Emergency Contact: ${profile.emergencyContactName} (${profile.relationship}) - ${profile.emergencyPhone}
🆔 Emergency ID: ${profile.qrId}
''';

    await Share.share(
      alertText,
      subject: '🆘 EMERGENCY MEDICAL CARD: ${profile.fullName}',
    );
  }
}
