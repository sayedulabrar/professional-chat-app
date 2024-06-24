import 'package:chat_app/widget/banner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import '/service/alert_service.dart';
import '/service/navigation_service.dart';
import '../constant/consts.dart';
import '../service/auth_service.dart';
import '../widget/custom_form_field.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GetIt _getIt = GetIt.instance;
  final _loginFormKey = GlobalKey<FormState>();
  String? email, password;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenHeight = mediaQuery.size.height;
    final double screenWidth = mediaQuery.size.width;
    return SafeArea(
        child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: [
          _headerText(),
          Lottie.asset(
            'assets/lottie_animations/Animation1718333394342.json',
            height: screenHeight * 0.2,
            width: screenWidth * 0.6,
          ),
          _loginForm(),
          _createAnAccountLink()
        ],
      ),
    ));
  }

  Widget _headerText() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: const Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hi, Welcome Back!",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            "Hello again!Yo have been missed ",
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
                color: Colors.grey),
          )
        ],
      ),
    );
  }

  Widget _loginForm() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.40,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.05,
      ),
      // EdgeInsets.symmetric                                                                                                                            Form(
      child: Form(
        key: _loginFormKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16.0), // Adjust padding as needed
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomFormField(
                height: MediaQuery.of(context).size.height * 0.1,
                hintText: "Email",
                validationRegEx: EMAIL_VALIDATION_REGEX,
                onsaved: (value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              CustomFormField(
                height: MediaQuery.of(context).size.height * 0.1,
                hintText: "Password",
                validationRegEx: PASSWORD_VALIDATION_REGEX,
                obscuretext: true,
                onsaved: (value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
              _loginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff2196F3), Color(0xff21CBF3)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius:
              BorderRadius.circular(8.0), // Add border radius if needed
        ),
        child: MaterialButton(
          onPressed: () async {
            if (_loginFormKey.currentState?.validate() ?? false) {
              _loginFormKey.currentState?.save();
              bool result = await _authService.login(email!, password!);

              if (result) {
                _navigationService.pushReplacementNamed("/home");
              } else {
                _alertService.showToast(
                    text: "Failed to login. Please try again!",
                    icon: Icons.error);
              }
            }
          },
          color: Colors.transparent,
          elevation: 0, // Remove elevation to see the gradient
          child: const Text(
            "Login",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _createAnAccountLink() {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text("Don't have an account?"),
          GestureDetector(
            onTap: () {
              _navigationService.pushNamed(
                  '/register'); //normally push this on login so he can come back here
            },
            child: const Text(
              "Sign Up",
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
