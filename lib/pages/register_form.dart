import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_flutter_nodejs/bloc/auth_cubits/auth_cubit.dart';
import 'package:task_manager_flutter_nodejs/pages/login_form.dart';
import 'package:task_manager_flutter_nodejs/utils/helper/auth_form.dart';
import 'package:task_manager_flutter_nodejs/utils/helper/auth_validator.dart';
import 'package:task_manager_flutter_nodejs/widgets/common_form.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _phoneController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthForm(
      title: "Create Account",
      subtitle: "Fill the form to register",
      formFields: [
        CommonFormField(
          controller: _nameController,
          label: 'Name',
          validator: AuthValidators.validateName,
          prefixIcon: Icons.person,
          autofillHints: const [AutofillHints.name],
        ),
        const SizedBox(height: 16),
        CommonFormField(
          controller: _emailController,
          label: 'Email',
          validator: AuthValidators.validateEmail,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email,
          autofillHints: const [AutofillHints.email],
        ),
        const SizedBox(height: 16),
        CommonFormField(
          controller: _phoneController,
          label: 'Phone Number',
          validator: AuthValidators.validatePhone,
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone,
          autofillHints: const [AutofillHints.telephoneNumber],
        ),
        const SizedBox(height: 16),
        CommonFormField(
          controller: _passwordController,
          label: 'Password',
          validator: AuthValidators.validatePassword,
          isPassword: true,
          prefixIcon: Icons.lock,
          autofillHints: const [AutofillHints.newPassword],
        ),
      ],
      submitButtonText: 'Submit',
      onSubmit: _submitForm,
      switchText: "Already have an account? Click ",
      switchPage: const LoginForm(),
      formKey: _formKey,
    );
  }
}
