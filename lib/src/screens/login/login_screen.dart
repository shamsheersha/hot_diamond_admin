import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/login/login_bloc.dart';
import 'package:hot_diamond_admin/src/controllers/login/login_event.dart';
import 'package:hot_diamond_admin/src/controllers/login/login_state.dart';
import 'package:hot_diamond_admin/src/model/admin_model/admin.dart';
import 'package:hot_diamond_admin/src/screens/login/widgets/custom_text_field.dart';
import 'package:hot_diamond_admin/src/services/admin_shared_preference/admin_shared_preference_helper.dart';
import 'package:hot_diamond_admin/src/screens/main_screen.dart';
import 'package:hot_diamond_admin/widgets/custom_button_widget.dart';
import 'package:hot_diamond_admin/widgets/show_custom_snackbar.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => LoginBloc(),
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const MainScreen()));
              showCustomSnackbar(context, "Login Successful!");
            } else if (state is LoginFailure) {
              showCustomSnackbar(context, state.error);
            }
          },
          builder: (context, state) {
            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/840ccc14-b0e1-4ec2-8b65-3332ab05c32b_page-0003.png',
                      width: double.infinity,
                      height: 280,
                      fit: BoxFit.cover,
                    ),
                    Expanded(
                        child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, -4))
                          ],
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30))),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Login',
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                "Please login to view ",
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              CustomTextfield(
                                controller: usernameController,
                                labelText: 'Username',
                                isPassword: false,
                                keyboardType: TextInputType.emailAddress, hintText: 'Username',
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              CustomTextfield(
                                controller: passwordController,
                                isPassword: true,
                                labelText: 'Password', hintText: 'Password',
                              ),
                              const SizedBox(height: 20),
                              if (state is LoginLoading)
                                const CircularProgressIndicator(color: Colors.black,)
                              else
                                CustomButton(
                                  onPressed: () async {
                                    final username =
                                        usernameController.text.trim();
                                    final password =
                                        passwordController.text.trim();

                                    if (username.isEmpty || password.isEmpty) {
                                      showCustomSnackbar(context,
                                          "Username and Password cannot be empty");
                                    } else {
                                      context.read<LoginBloc>().add(
                                          LoginButtonPressed(
                                              username: username,
                                              password: password));
                                    }
                                  },
                                  text: 'Login', style:const ButtonStyle(),
                                ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    )),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<bool> _validateCredentials(String username, String password) async {
    // Fetch the stored credentials from SharedPreferences
    AdminCredentials storedCredentials =
        await SharedPrefsHelper.getCredentials();
    return username == storedCredentials.username &&
        password == storedCredentials.password;
  }
}
