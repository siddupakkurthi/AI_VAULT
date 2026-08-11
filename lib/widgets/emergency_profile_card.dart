import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants/app_colors.dart';
import '../models/medical_profile.dart';
import '../services/sos_service.dart';

class EmergencyProfileCard extends StatelessWidget {
  final MedicalProfile profile;
  final bool showHeaderBanner;
  final VoidCallback? onClose;

  const EmergencyProfileCard({
    super.key,
    required this.profile,
    this.showHeaderBanner = true,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = profile.fullName.trim().isNotEmpty ? profile.fullName : 'Not available';
    final ageText = profile.age > 0 ? '${profile.age} years' : 'Not available';
    final genderText = profile.gender.trim().isNotEmpty ? profile.gender : 'Not available';
    final bloodText = profile.bloodGroup.trim().isNotEmpty ? profile.bloodGroup : 'Not available';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F081A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFDC2626).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC2626).withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------------------------------------------------------------------
          // 1. HEADER SECTION
          // -------------------------------------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF991B1B), Color(0xFF7F1D1D), Color(0xFF450A0A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.health_and_safety_rounded, color: Colors.yellowAccent, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Emergency Medical Profile',
                                style: TextStyle(
                                  color: Colors.yellowAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onClose != null) ...[
                      GestureDetector(
                        onTap: onClose,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Prominent Blood Group Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            profile.bloodGroup.isNotEmpty ? profile.bloodGroup : '?',
                            style: const TextStyle(
                              color: Color(0xFFB91C1C),
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                            ),
                          ),
                          const Text(
                            'BLOOD',
                            style: TextStyle(
                              color: Color(0xFFB91C1C),
                              fontWeight: FontWeight.w800,
                              fontSize: 9,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -------------------------------------------------------------
                // 2. BASIC INFORMATION
                // -------------------------------------------------------------
                _buildSectionHeader(
                  title: 'Basic Information',
                  icon: Icons.person_outline_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1B1229) : const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildInfoGridItem('Name', name, isDark),
                      ),
                      Expanded(
                        child: _buildInfoGridItem('Age', ageText, isDark),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1B1229) : const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildInfoGridItem('Gender', genderText, isDark),
                      ),
                      Expanded(
                        child: _buildInfoGridItem('Blood Group', bloodText, isDark),
                      ),
                    ],
                  ),
                ),
                if (profile.height > 0 || profile.weight > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1B1229) : const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.straighten_rounded, size: 16, color: AppColors.textMuted),
                        const SizedBox(width: 8),
                        Text(
                          'Height: ${profile.height > 0 ? '${profile.height.toInt()} cm' : 'N/A'}   •   Weight: ${profile.weight > 0 ? '${profile.weight.toInt()} kg' : 'N/A'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // -------------------------------------------------------------
                // 3. CRITICAL MEDICAL INFORMATION
                // -------------------------------------------------------------
                _buildSectionHeader(
                  title: 'Critical Medical Information',
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFEF4444),
                ),
                const SizedBox(height: 10),

                // Allergies (Red Box)
                _buildMedicalAlertCard(
                  title: 'Allergies',
                  items: profile.allergies,
                  emptyText: 'No known allergies recorded',
                  color: const Color(0xFFEF4444),
                  bgColor: isDark ? const Color(0xFF2E0909) : const Color(0xFFFEF2F2),
                  borderColor: const Color(0xFFEF4444),
                  icon: Icons.cancel_rounded,
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 10),

                // Diseases / Medical Conditions (Amber Box)
                _buildMedicalAlertCard(
                  title: 'Medical Conditions / Diseases',
                  items: profile.diseases,
                  emptyText: 'No medical conditions recorded',
                  color: const Color(0xFFF59E0B),
                  bgColor: isDark ? const Color(0xFF2E1C04) : const Color(0xFFFFFBEB),
                  borderColor: const Color(0xFFF59E0B),
                  icon: Icons.local_hospital_rounded,
                ).animate(delay: 100.ms).fadeIn(),

                const SizedBox(height: 10),

                // Current Medications (Blue Box)
                _buildMedicalAlertCard(
                  title: 'Current Medications',
                  items: profile.medications,
                  emptyText: 'No current medications recorded',
                  color: const Color(0xFF3B82F6),
                  bgColor: isDark ? const Color(0xFF091E42) : const Color(0xFFEFF6FF),
                  borderColor: const Color(0xFF3B82F6),
                  icon: Icons.medication_rounded,
                ).animate(delay: 150.ms).fadeIn(),

                const SizedBox(height: 20),

                // -------------------------------------------------------------
                // 4. EMERGENCY CONTACT
                // -------------------------------------------------------------
                _buildSectionHeader(
                  title: 'Emergency Contact',
                  icon: Icons.phone_in_talk_rounded,
                  color: const Color(0xFF10B981),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF062D24) : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.contact_phone_rounded,
                                color: Color(0xFF10B981), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.emergencyContactName.trim().isNotEmpty
                                      ? profile.emergencyContactName
                                      : 'Not available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? Colors.white : AppColors.textDark,
                                  ),
                                ),
                                if (profile.relationship.trim().isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Relationship: ${profile.relationship}',
                                    style: const TextStyle(
                                      color: Color(0xFF10B981),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 2),
                                Text(
                                  profile.emergencyPhone.trim().isNotEmpty
                                      ? profile.emergencyPhone
                                      : 'No phone number listed',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (profile.emergencyPhone.trim().isNotEmpty) ...[
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => SosService.makePhoneCall(profile.emergencyPhone),
                            icon: const Icon(Icons.call_rounded, color: Colors.white, size: 18),
                            label: Text(
                              '🆘 CALL EMERGENCY CONTACT (${profile.emergencyPhone})',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC2626),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ).animate(delay: 200.ms).fadeIn(),

                if (profile.medicalNotes.trim().isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildSectionHeader(
                    title: 'Medical Notes',
                    icon: Icons.assignment_rounded,
                    color: const Color(0xFF6366F1),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      profile.medicalNotes,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ).animate(delay: 220.ms).fadeIn(),
                ],

                const SizedBox(height: 20),

                // -------------------------------------------------------------
                // 5. ORGAN DONOR STATUS
                // -------------------------------------------------------------
                _buildSectionHeader(
                  title: 'Organ Donor Status',
                  icon: Icons.favorite_rounded,
                  color: const Color(0xFFEC4899),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: profile.isOrganDonor
                        ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5))
                        : (isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: profile.isOrganDonor
                          ? const Color(0xFF10B981)
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        color: profile.isOrganDonor ? const Color(0xFF10B981) : Colors.grey,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Organ Donor: ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: profile.isOrganDonor
                              ? const Color(0xFF10B981)
                              : Colors.grey.shade600,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          profile.isOrganDonor ? 'YES' : 'NO',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 250.ms).fadeIn(),

                const SizedBox(height: 20),

                // -------------------------------------------------------------
                // 6. AI EMERGENCY SUMMARY
                // -------------------------------------------------------------
                if (profile.aiSummary.trim().isNotEmpty) ...[
                  _buildSectionHeader(
                    title: 'AI Emergency Summary',
                    icon: Icons.psychology_rounded,
                    color: const Color(0xFFA78BFA),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1035) : const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded, color: Color(0xFFA78BFA), size: 18),
                            SizedBox(width: 8),
                            Text(
                              'AI EMERGENCY SUMMARY',
                              style: TextStyle(
                                color: Color(0xFFA78BFA),
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          profile.aiSummary,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : const Color(0xFF2D1554),
                            fontSize: 13,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 300.ms).fadeIn(),
                  const SizedBox(height: 16),
                ],

                if (profile.qrId.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'QR ID: ${profile.qrId}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGridItem(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textDark,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildMedicalAlertCard({
    required String title,
    required List<String> items,
    required String emptyText,
    required Color color,
    required Color bgColor,
    required Color borderColor,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: items.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 6, color: color),
                      const SizedBox(width: 6),
                      Text(
                        item,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
          else
            Text(
              emptyText,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}
