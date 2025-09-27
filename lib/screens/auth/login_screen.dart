import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:shop_smart/admin/admin_dashboard.dart';
import 'package:shop_smart/consts/validater.dart';
import 'package:shop_smart/providers/user_provider.dart';
import 'package:shop_smart/root_screen.dart';
import 'package:shop_smart/screens/auth/forgot_password.dart';
import 'package:shop_smart/screens/auth/google_btn.dart';
import 'package:shop_smart/screens/auth/register_screen.dart';
import 'package:shop_smart/screens/loading_manager.dart';
import 'package:shop_smart/widgets/app_name_text.dart';
import 'package:shop_smart/widgets/subtitle_text.dart';
import 'package:shop_smart/widgets/title_text.dart';

class LoginScreen extends StatefulWidget {
  static const routName = "/LoginScreen";
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;

  final _formkey = GlobalKey<FormState>();
  bool _isLoading = false;
  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    // Focus Nodes
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    if (mounted) {
      _emailController.dispose();
      _passwordController.dispose();
      // Focus Nodes
      _emailFocusNode.dispose();
      _passwordFocusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _loginFct(BuildContext context) async {
  final isValid = _formkey.currentState!.validate();
  FocusScope.of(context).unfocus();
  if (!isValid) return;

  setState(() {
    _isLoading = true;
  });

  final userProvider = Provider.of<UserProvider>(context, listen: false);

  try {
    final errorMessage = await userProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return;
    }

    // Navigate based on role
    final user = userProvider.getUser;
    if (user != null) {
      if (user.role == 'admin') {
        Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
      } else {
        Navigator.pushReplacementNamed(context, RootScreen.routName);
      }
    }
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: LoadngManager(
          isLoading: _isLoading,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  const AppNameTextWidget(fontSize: 30),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: TitlesTextWidget(label: "Welcome back!"),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: "Email address",
                            prefixIcon: Icon(IconlyLight.message),
                          ),
                          onFieldSubmitted: (value) {
                            FocusScope.of(
                              context,
                            ).requestFocus(_passwordFocusNode);
                          },
                          validator: (value) {
                            return MyValidators.emailValidator(value);
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: const InputDecoration(
                            hintText: "***********",
                            prefixIcon: Icon(IconlyLight.lock),
                          ),
                          onFieldSubmitted: (value) async {
                            await _loginFct(context);
                          },
                          validator: (value) {
                            return MyValidators.passwordValidator(value);
                          },
                        ),
                        const SizedBox(height: 16.0),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(
                                context,
                              ).pushNamed(ForgotPasswordScreen.routeName);
                            },
                            child: const SubtitleTextWidget(
                              label: "Forgot password?",
                              fontStyle: FontStyle.italic,
                              textDecoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(12.0),
                              // backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            icon: const Icon(Icons.login),
                            label: const Text("Login"),
                            onPressed: () async {
                              await _loginFct(context);
                            },
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        SubtitleTextWidget(
                          label: "Or connect using".toUpperCase(),
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: kBottomNavigationBarHeight,

                                child: GoogleButton(),
                              ),
                            ),

                            SizedBox(width: 20),
                            Expanded(
                              child: SizedBox(
                                height: kBottomNavigationBarHeight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(12.0),
                                    // backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  child: const Text("Guest?"),
                                  onPressed: () async {
                                    Navigator.pushNamed(
                                      context,
                                      RootScreen.routName,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        FittedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                child: SubtitleTextWidget(
                                  label: "Don't have an account?",
                                ),
                              ),

                              SizedBox(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      RegisterScreen.routName,
                                    );
                                  },
                                  child: SizedBox(
                                    child: const SubtitleTextWidget(
                                      label: "Create One?",
                                      fontStyle: FontStyle.italic,
                                      textDecoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                              
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
