import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/utils/notifier.dart';
import 'package:etqan_application_2025/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:etqan_application_2025/src/features/auth/presentation/widgets/auth_btn.dart';
import 'package:etqan_application_2025/src/features/auth/presentation/widgets/auth_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  // _SignupPageState createState() => _SignupPageState();
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // formKey.currentState!.validate();
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthFailure) {
                SmartNotifier.error(context,
                    title: AppLocalizations.of(context)!.error,
                    message: state.message);
              }
            },
            builder: (context, state) {
              if (state is AuthLoading) {
                return const Loader();
              }
              return Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    Text(AppLocalizations.of(context)!.signIn,
                        style: TextStyle(
                            fontSize: 50, fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    AuthField(
                      hintText: AppLocalizations.of(context)!.email,
                      controller: emailController,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    AuthField(
                      hintText: AppLocalizations.of(context)!.password,
                      controller: passwordController,
                      isObscureText: true,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    AuthBtn(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                                AuthSignIn(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                ),
                              );
                        }
                      },
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
