import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_flutter_nodejs/bloc/auth_cubits/auth_cubit.dart';
import 'package:task_manager_flutter_nodejs/bloc/task_cubits/task_cubit.dart';
import 'package:task_manager_flutter_nodejs/bloc/user_cubits/user_cubit.dart';
import 'package:task_manager_flutter_nodejs/config/theme.dart';
import 'package:task_manager_flutter_nodejs/pages/home_page.dart';
import 'package:task_manager_flutter_nodejs/pages/login_form.dart';
import 'package:task_manager_flutter_nodejs/pages/register_form.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => UserCubit()),
        BlocProvider(create: (_) => TaskCubit()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: RegisterForm(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginForm(),
        '/register': (context) => const RegisterForm(),
        '/home': (context) => const HomePage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
