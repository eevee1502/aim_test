import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/services/local_storage_service.dart';
import '../core/theme/aim_color.dart';
import 'home/home_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormBuilderState>();
  List<Widget> _pages = [];
  late AnimationController _controller;

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _termsChecked = false;
  bool _privacyChecked = false;

  @override
  void initState() {
    super.initState();
    _pages = [_buildIdStep()];
    _controller = AnimationController(
      duration: const Duration(milliseconds:300),
      vsync: this,
    );
  }

  void _nextStep() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        Widget nextStepWidget = _getNextStepWidget();
        if (nextStepWidget != Container()) {
          _pages.insert(0, nextStepWidget);
        }
      });
      _controller.forward(from: 0);
    }
  }

  Widget _getNextStepWidget() {
    switch (_pages.length) {
      case 1:
        return _buildPasswordStep();
      case 2:
        return _buildPhoneNumberStep();
      case 3:
        return _buildEmailStep();
      case 4:
        return _buildAgreementStep();
      default:
        _saveAndProceed();
        return Container();
    }
  }

  Future<void> _saveAndProceed() async {
    final localStorage = LocalStorageService();
    await localStorage.saveData("user_id", "test_id");

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AimColors.background,
      appBar: AppBar(
        backgroundColor: AimColors.background,
        elevation: 0,
        actions: [
          Text("상위 1% 자산관리를 당신에게 AIM®"),
          SizedBox(width: 16)
        ],
      ),
      body: FormBuilder(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 8),
                reverse: false,
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _pages,
                  ),
                ),
              ),
            ),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIdStep() {
    return _buildStep(
      "ID를 입력해주세요.",
      FormBuilderTextField(
        name: "id",
        controller: _idController,
        decoration: _inputDecoration("ID", "영문 7자 이상"),
        autovalidateMode: AutovalidateMode.onUnfocus,
        validator: (value) {
          if (value == null || value.length < 7) {
            return "ID는 7자 이상 입력해야 합니다.";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordStep() {
    return _buildStep(
      "비밀번호를 입력해주세요.",
      Column(
        children: [
          FormBuilderTextField(
            name: "password",
            controller: _passwordController,
            obscureText: true,
            decoration: _inputDecoration("비밀번호", "대소문자, 숫자, 특수문자 포함 10자 이상"),
            autovalidateMode: AutovalidateMode.onUnfocus,
            validator: (value) {
              if (value == null || value.length < 10 ||
                  !RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])').hasMatch(value)) {
                return "비밀번호는 대소문자, 숫자, 특수문자를 포함하고 10자 이상이어야 합니다.";
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          FormBuilderTextField(
            name: "confirm_password",
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: _inputDecoration("비밀번호 확인", "비밀번호를 다시 입력해주세요"),
            autovalidateMode: AutovalidateMode.onUnfocus,
            validator: (value) {
              if (value != _formKey.currentState?.fields['password']?.value) {
                return "비밀번호가 일치하지 않습니다.";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneNumberStep() {
    return _buildStep(
      "휴대폰 번호를 입력해주세요.",
      FormBuilderTextField(
        name: "phone",
        controller: _phoneController,
        decoration: _inputDecoration("휴대폰 번호", "010********"),
        keyboardType: TextInputType.phone,
        autovalidateMode: AutovalidateMode.onUnfocus,
        validator: (value) {
          if (value == null || !RegExp(r'^010\d{8}$').hasMatch(value)) {
            return "올바른 휴대폰 번호를 입력해주세요.";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildEmailStep() {
    return _buildStep(
      "이메일을 입력해주세요.",
      FormBuilderTextField(
        name: "email",
        controller: _emailController,
        decoration: _inputDecoration("이메일", "example@domain.com"),
        keyboardType: TextInputType.emailAddress,
        autovalidateMode: AutovalidateMode.onUnfocus,
        onChanged: (value) {
          setState(() {
            _formKey.currentState?.fields['email']?.validate();
          });
        },
        validator: (value) {
          if (_emailController.text == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text)) {
            return "올바른 이메일을 입력해주세요.";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildAgreementStep() {
    return _buildStep(
      "AIM 이용약관에 동의해주세요.",
      Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12, width: 1),
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
            padding: const EdgeInsets.all(8),
            child: FormBuilderField<bool>(
              name: "all_agree",
              initialValue: false,
              builder: (FormFieldState<bool> field) {
                return Row(
                  children: [
                    Checkbox(
                      value: field.value ?? false,
                      onChanged: (value) {
                        setState(() {
                          bool isChecked = value ?? false;
                          field.didChange(isChecked);
                          _formKey.currentState?.fields['term']?.didChange(isChecked);
                          _formKey.currentState?.fields['privacy']?.didChange(isChecked);

                          _updateAllAgreeState();
                        });
                      },
                      activeColor: AimColors.primary,
                      checkColor: Colors.white,
                      shape: const CircleBorder(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                        "모든 약관에 동의합니다.",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildAgreementItem(
            name: "term",
            text: "[필수] AIM 이용약관",
            url: "https://assets.getaim.co/assets/agreements/user_agreement_1.0.html",
          ),
          _buildAgreementItem(
            name: "privacy",
            text: "[필수] 개인정보 수집이용 동의",
            url: "https://assets.getaim.co/assets/agreements/privacy_agreement_3.7.html",
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementItem({required String name, required String text, required String url}) {
    return FormBuilderField<bool>(
      name: name,
      builder: (FormFieldState<bool> field) {
        return Container(
          padding: EdgeInsets.symmetric(vertical:8),
          child: Row(
            children: [
              Checkbox(
                value: field.value ?? false,
                onChanged: (value) {
                  setState(() {
                    field.didChange(value);
                    _updateAllAgreeState();
                  });
                },
                activeColor: AimColors.primary,
                checkColor: Colors.white,
                shape: const CircleBorder(),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _launchURL(url),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(text),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ],
          )
        );
      },
    );
  }

  void _updateAllAgreeState() {
    _termsChecked = _formKey.currentState?.fields['term']?.value ?? false;
    _privacyChecked = _formKey.currentState?.fields['privacy']?.value ?? false;

    bool isAllChecked = _termsChecked && _privacyChecked;

    setState(() {
      _formKey.currentState?.fields['all_agree']?.didChange(isAllChecked);
    });
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw "Could not launch $url";
    }
  }

  Widget _buildStep(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            child,
          ]
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelStyle: TextStyle(
          color: AimColors.primary
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AimColors.primary, width: 2),
      ),
      label: Text(label),
      hintText: hint,
    );
  }

  Widget _buildNextButton() {
    bool isNextEnabled = true;
    int currentStep = _pages.length;

    if (currentStep > 4) {
      isNextEnabled = _termsChecked && _privacyChecked;
    }
    Radius radius = Radius.circular(8);

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).viewPadding.bottom+56,
      child: SafeArea(
        child: ElevatedButton(
          onPressed: isNextEnabled ? _nextStep : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isNextEnabled ? AimColors.primary : AimColors.primary.withOpacity(0.5),
            foregroundColor: AimColors.background,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
            ),
          ),
          child: Text(
            "다음",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
