import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_flutter_nodejs/bloc/auth_cubits/auth_cubit.dart';
import 'package:task_manager_flutter_nodejs/pages/register_form.dart';
import 'package:task_manager_flutter_nodejs/utils/helper/auth_form.dart';
import 'package:task_manager_flutter_nodejs/utils/helper/auth_validator.dart';
import 'package:task_manager_flutter_nodejs/widgets/common_form.dart';

class LoginForm extends StatefulWidget {
  final String? infoMessage;

  const LoginForm({super.key, this.infoMessage});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthForm(
      title: "Welcome Back",
      subtitle: "Enter your credential to login",
      formFields: [
        CommonFormField(
          controller: _usernameController,
          label: 'Email',
          validator: AuthValidators.validateEmail,
          prefixIcon: Icons.person,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
        ),
        const SizedBox(height: 16),
        CommonFormField(
          controller: _passwordController,
          label: 'Password',
          isPassword: true,
          validator: AuthValidators.validatePassword,
          prefixIcon: Icons.lock,
          autofillHints: const [AutofillHints.password],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // Implement forgot password functionality
            },
            child: const Text("Forgot password?"),
          ),
        ),
      ],
      submitButtonText: 'Login',
      onSubmit: _submitForm,
      infoMessage: widget.infoMessage,
      switchText: "Don't have an account? Click ",
      switchPage: const RegisterForm(),
      formKey: _formKey,
    );
  }
}
