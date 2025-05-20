import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_flutter_nodejs/bloc/auth_cubits/auth_cubit.dart';
import 'package:task_manager_flutter_nodejs/bloc/auth_cubits/auth_state.dart';
import 'package:task_manager_flutter_nodejs/pages/login_form.dart';
import 'home_page.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is AuthUnauthenticated) {
          return LoginForm();
        } else if (state is AuthAuthenticated) {
          return HomePage();
        } else if (state is AuthRegistered) {
          return LoginForm(
            infoMessage: "Registration successful! Please login.",
          );
        } else {
          // Default fallback to login page
          return LoginForm();
        }
      },
    );
  }
}
