import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../models/medical_profile.dart';
import '../../widgets/common_widgets.dart';

class CreateEditProfileScreen extends StatefulWidget {
  final bool isEditing;

  const CreateEditProfileScreen({super.key, required this.isEditing});

  @override
  State<CreateEditProfileScreen> createState() => _CreateEditProfileScreenState();
}

class _CreateEditProfileScreenState extends State<CreateEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  // Controllers
  final _nameCtrl = TextEditingController();
  final _userPhoneCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _contactNameCtrl = TextEditingController();
  final _contactPhoneCtrl = TextEditingController();
  final _medicalNotesCtrl = TextEditingController();
  final _allergyInputCtrl = TextEditingController();
  final _diseaseInputCtrl = TextEditingController();
  final _medicationInputCtrl = TextEditingController();

  String _selectedGender = '';
  String _selectedBloodGroup = '';
  String _selectedRelationship = '';
  bool _isOrganDonor = false;
  List<String> _allergies = [];
  List<String> _diseases = [];
  List<String> _medications = [];

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final profile = profileProvider.profile;

    if (widget.isEditing && profile != null) {
      _populateFromProfile(profile);
    } else {
      if (profile != null) {
        if (profile.fullName.isNotEmpty) _nameCtrl.text = profile.fullName;
        if (profile.userPhone.isNotEmpty) _userPhoneCtrl.text = profile.userPhone;
      } else if (authProvider.user != null) {
        final name = authProvider.displayName;
        if (name.isNotEmpty && name != 'Guest User' && !name.contains('@')) {
          _nameCtrl.text = name;
        }
      }
    }
  }

  void _populateFromProfile(MedicalProfile p) {
    _nameCtrl.text = p.fullName;
    _userPhoneCtrl.text = p.userPhone;
    _ageCtrl.text = p.age > 0 ? p.age.toString() : '';
    _heightCtrl.text = p.height > 0 ? p.height.toString() : '';
    _weightCtrl.text = p.weight > 0 ? p.weight.toString() : '';
    _contactNameCtrl.text = p.emergencyContactName;
    _contactPhoneCtrl.text = p.emergencyPhone;
    _medicalNotesCtrl.text = p.medicalNotes;
    _selectedGender = p.gender;
    _selectedBloodGroup = p.bloodGroup;
    _selectedRelationship = p.relationship;
    _isOrganDonor = p.isOrganDonor;
    _allergies = List.from(p.allergies);
    _diseases = List.from(p.diseases);
    _medications = List.from(p.medications);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _userPhoneCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _contactNameCtrl.dispose();
    _contactPhoneCtrl.dispose();
    _medicalNotesCtrl.dispose();
    _allergyInputCtrl.dispose();
    _diseaseInputCtrl.dispose();
    _medicationInputCtrl.dispose();
    super.dispose();
  }

  /// Validates only the fields relevant to the given step.
  bool _validateCurrentStep() {
    final formState = _formKey.currentState;
    if (formState == null) return true;
    // We use individual field validators so trigger full validate
    // but only block on step-specific required fields
    if (_currentStep == 0) {
      if (_nameCtrl.text.trim().isEmpty) {
        _showValidationSnackbar('Please enter your full name');
        return false;
      }
      final age = int.tryParse(_ageCtrl.text.trim());
      if (age == null || age <= 0 || age > 120) {
        _showValidationSnackbar('Please enter a valid age (1–120)');
        return false;
      }
      if (_selectedBloodGroup.isEmpty) {
        _showValidationSnackbar('Please select a blood group');
        return false;
      }
    } else if (_currentStep == 2) {
      if (_contactNameCtrl.text.trim().isEmpty) {
        _showValidationSnackbar('Please enter the emergency contact name');
        return false;
      }
      if (_contactPhoneCtrl.text.trim().isEmpty) {
        _showValidationSnackbar('Please enter the emergency contact phone');
        return false;
      }
    }
    return true;
  }

  void _showValidationSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _goToPage(int page) {
    setState(() => _currentStep = page);
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _saveProfile() async {
    if (!_validateCurrentStep()) return;

    final profileProvider = context.read<ProfileProvider>();
    MedicalProfile profile;

    if (widget.isEditing && profileProvider.profile != null) {
      profile = profileProvider.profile!.copyWith(
        fullName: _nameCtrl.text.trim(),
        userPhone: _userPhoneCtrl.text.trim(),
        age: int.tryParse(_ageCtrl.text) ?? 0,
        gender: _selectedGender,
        bloodGroup: _selectedBloodGroup,
        height: double.tryParse(_heightCtrl.text) ?? 0,
        weight: double.tryParse(_weightCtrl.text) ?? 0,
        emergencyContactName: _contactNameCtrl.text.trim(),
        emergencyPhone: _contactPhoneCtrl.text.trim(),
        relationship: _selectedRelationship,
        allergies: _allergies,
        diseases: _diseases,
        medications: _medications,
        isOrganDonor: _isOrganDonor,
        medicalNotes: _medicalNotesCtrl.text.trim(),
        updatedAt: DateTime.now(),
      );
    } else {
      profile = profileProvider.createEmptyProfile().copyWith(
        fullName: _nameCtrl.text.trim(),
        userPhone: _userPhoneCtrl.text.trim(),
        age: int.tryParse(_ageCtrl.text) ?? 0,
        gender: _selectedGender,
        bloodGroup: _selectedBloodGroup,
        height: double.tryParse(_heightCtrl.text) ?? 0,
        weight: double.tryParse(_weightCtrl.text) ?? 0,
        emergencyContactName: _contactNameCtrl.text.trim(),
        emergencyPhone: _contactPhoneCtrl.text.trim(),
        relationship: _selectedRelationship,
        allergies: _allergies,
        diseases: _diseases,
        medications: _medications,
        isOrganDonor: _isOrganDonor,
        medicalNotes: _medicalNotesCtrl.text.trim(),
      );
    }

    await profileProvider.saveProfile(profile);
    if (mounted) {
      if (profileProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(profileProvider.errorMessage!)),
              ],
            ),
            backgroundColor: AppColors.emergency,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text('Profile saved successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        context.go('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkGradient : null,
          color: isDark ? null : AppColors.lightBg,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, isDark),
              _buildStepIndicator(isDark),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep1PersonalInfo(isDark),
                      _buildStep2MedicalInfo(isDark),
                      _buildStep3Emergency(isDark),
                    ],
                  ),
                ),
              ),
              _buildNavigationButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/dashboard'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: isDark ? Colors.white : AppColors.textDark),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEditing ? 'Edit Profile' : 'Create Profile',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              Text(
                'Step ${_currentStep + 1} of 3',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                decoration: BoxDecoration(
                  gradient: isDone || isActive
                      ? AppColors.primaryGradient
                      : null,
                  color: isDone || isActive
                      ? null
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1PersonalInfo(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Basic Information',
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _nameCtrl,
            label: 'Full Name *',
            icon: Icons.person_outline,
            validator: (v) => v!.trim().isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 14),

          _buildTextField(
            controller: _userPhoneCtrl,
            label: 'Your Phone Number',
            icon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
            hint: 'e.g. +1 234 567 8900',
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _ageCtrl,
                  label: 'Age *',
                  icon: Icons.cake_rounded,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final age = int.tryParse(v ?? '');
                    if (age == null || age <= 0 || age > 120) return 'Enter valid age';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: 'Gender',
                  value: _selectedGender.isEmpty ? null : _selectedGender,
                  items: AppStrings.genders,
                  onChanged: (v) => setState(() => _selectedGender = v ?? ''),
                  icon: Icons.wc_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildDropdown(
            label: 'Blood Group *',
            value: _selectedBloodGroup.isEmpty ? null : _selectedBloodGroup,
            items: AppStrings.bloodGroups,
            onChanged: (v) => setState(() => _selectedBloodGroup = v ?? ''),
            icon: Icons.water_drop_rounded,
            color: AppColors.bloodRed,
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _heightCtrl,
                  label: 'Height (cm)',
                  icon: Icons.height_rounded,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _weightCtrl,
                  label: 'Weight (kg)',
                  icon: Icons.monitor_weight_rounded,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStep2MedicalInfo(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Medical Information',
            icon: Icons.medical_information_rounded,
            iconColor: AppColors.emergency,
          ),
          const SizedBox(height: 20),

          _buildChipInputSection(
            title: 'Allergies',
            icon: Icons.warning_amber_rounded,
            color: AppColors.emergency,
            hint: 'e.g. Penicillin, Nuts',
            controller: _allergyInputCtrl,
            chips: _allergies,
            onAdd: () {
              final text = _allergyInputCtrl.text.trim();
              if (text.isNotEmpty && !_allergies.contains(text)) {
                setState(() {
                  _allergies.add(text);
                  _allergyInputCtrl.clear();
                });
              }
            },
            onRemove: (item) => setState(() => _allergies.remove(item)),
          ),
          const SizedBox(height: 16),

          _buildChipInputSection(
            title: 'Existing Diseases / Conditions',
            icon: Icons.local_hospital_rounded,
            color: AppColors.warning,
            hint: 'e.g. Diabetes, Hypertension',
            controller: _diseaseInputCtrl,
            chips: _diseases,
            onAdd: () {
              final text = _diseaseInputCtrl.text.trim();
              if (text.isNotEmpty && !_diseases.contains(text)) {
                setState(() {
                  _diseases.add(text);
                  _diseaseInputCtrl.clear();
                });
              }
            },
            onRemove: (item) => setState(() => _diseases.remove(item)),
          ),
          const SizedBox(height: 16),

          _buildChipInputSection(
            title: 'Current Medications',
            icon: Icons.medication_rounded,
            color: AppColors.info,
            hint: 'e.g. Metformin 500mg, Insulin',
            controller: _medicationInputCtrl,
            chips: _medications,
            onAdd: () {
              final text = _medicationInputCtrl.text.trim();
              if (text.isNotEmpty && !_medications.contains(text)) {
                setState(() {
                  _medications.add(text);
                  _medicationInputCtrl.clear();
                });
              }
            },
            onRemove: (item) => setState(() => _medications.remove(item)),
          ),
          const SizedBox(height: 16),

          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.favorite_rounded, color: AppColors.success, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Organ Donor',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text('Willing to donate organs',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
                Switch(
                  value: _isOrganDonor,
                  onChanged: (v) => setState(() => _isOrganDonor = v),
                  activeColor: AppColors.success,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: _medicalNotesCtrl,
            label: 'Additional Medical Notes',
            icon: Icons.notes_rounded,
            maxLines: 3,
            hint: 'e.g. Previous surgeries, implants, special instructions...',
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStep3Emergency(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Emergency Contact',
            icon: Icons.phone_in_talk_rounded,
            iconColor: AppColors.emergency,
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _contactNameCtrl,
            label: 'Contact Name *',
            icon: Icons.person_outline,
            validator: (v) => v!.trim().isEmpty ? 'Contact name is required' : null,
          ),
          const SizedBox(height: 14),

          _buildTextField(
            controller: _contactPhoneCtrl,
            label: 'Phone Number *',
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
            validator: (v) => v!.trim().isEmpty ? 'Phone number is required' : null,
          ),
          const SizedBox(height: 14),

          _buildDropdown(
            label: 'Relationship',
            value: _selectedRelationship.isEmpty ? null : _selectedRelationship,
            items: AppStrings.relationships,
            onChanged: (v) => setState(() => _selectedRelationship = v ?? ''),
            icon: Icons.people_rounded,
          ),
          const SizedBox(height: 24),

          GlassCard(
            padding: const EdgeInsets.all(16),
            borderColor: AppColors.primary.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.psychology_rounded, color: AppColors.primary, size: 18),
                    SizedBox(width: 8),
                    Text('AI Summary',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'After saving, our AI will automatically generate a medical summary prioritizing critical information for first responders.',
                  style: TextStyle(
                    color: isDark ? AppColors.textMuted : Colors.grey,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildChipInputSection({
    required String title,
    required IconData icon,
    required Color color,
    required String hint,
    required TextEditingController controller,
    required List<String> chips,
    required VoidCallback onAdd,
    required Function(String) onRemove,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: color, width: 1.5),
                    ),
                    filled: true,
                    fillColor: isDark ? AppColors.darkBg.withValues(alpha: 0.5) : Colors.grey.shade50,
                  ),
                  onSubmitted: (_) => onAdd(),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Icon(Icons.add, color: color, size: 20),
                ),
              ),
            ],
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: chips
                  .map((c) => InfoChip(
                        label: c,
                        color: color,
                        onDelete: () => onRemove(c),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      textInputAction: maxLines == 1 ? TextInputAction.next : TextInputAction.newline,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
    Color? color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: color ?? AppColors.primary),
      ),
      dropdownColor: isDark ? AppColors.darkCard : Colors.white,
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: TextStyle(color: isDark ? Colors.white : AppColors.textDark)),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ProfileProvider>();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: provider.isLoading
                    ? null
                    : () => _goToPage(_currentStep - 1),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back', style: TextStyle(color: AppColors.primary)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GradientButton(
              label: _currentStep < 2 ? 'Continue' : 'Save Profile',
              icon: _currentStep < 2 ? Icons.arrow_forward_rounded : Icons.check_rounded,
              isLoading: provider.isLoading,
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      if (_currentStep < 2) {
                        if (_validateCurrentStep()) {
                          _goToPage(_currentStep + 1);
                        }
                      } else {
                        await _saveProfile();
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}
