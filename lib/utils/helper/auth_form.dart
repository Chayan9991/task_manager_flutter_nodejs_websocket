import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_flutter_nodejs/bloc/auth_cubits/auth_cubit.dart';
import 'package:task_manager_flutter_nodejs/bloc/auth_cubits/auth_state.dart';
import 'package:task_manager_flutter_nodejs/pages/login_form.dart';

class AuthForm extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> formFields;
  final String submitButtonText;
  final VoidCallback onSubmit;
  final String? infoMessage;
  final String switchText;
  final Widget switchPage;
  final GlobalKey<FormState> formKey;

  const AuthForm({
    super.key,
    required this.title,
    required this.subtitle,
    required this.formFields,
    required this.submitButtonText,
    required this.onSubmit,
    this.infoMessage,
    required this.switchText,
    required this.switchPage,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    // Show infoMessage SnackBar if provided
    if (infoMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(infoMessage!)));
      });
    }

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        } else if (state is AuthRegistered) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (_) => const LoginForm(
                    infoMessage: "Registration successful! Please login.",
                  ),
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        bool isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width > 600 ? 200 : 24,
                vertical: 32,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 30),
                      Center(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ...formFields,
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: isLoading ? null : onSubmit,
                        child:
                            isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : Text(submitButtonText),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            switchText,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => switchPage),
                              );
                            },
                            child: const Text(
                              "here",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
