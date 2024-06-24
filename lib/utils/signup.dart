import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import '/models/profile.dart';
import '/service/alert_service.dart';
import '/service/database_service.dart';
import '/service/media_service.dart';
import '/service/navigation_service.dart';
import '/service/storage_service.dart';
import '../constant/consts.dart';
import '../service/auth_service.dart';
import '../widget/custom_form_field.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final GetIt _getIt = GetIt.instance;
  final _signupFormKey = GlobalKey<FormState>();
  String name = "";
  String email = "";
  String password = "";
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late MediaService _mediaService;
  late StorageService _storageService;
  File? selectedimage;
  late DatabaseService _databaseService;
  bool isloading = false;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();
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
          if (!isloading) _signupForm(),
          if (!isloading) _loginLink(),
          if (isloading)
            const Expanded(
                child: Center(
              child: CircularProgressIndicator(),
            ))
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
            "Welcome!",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            "Create a new account",
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
                color: Colors.grey),
          )
        ],
      ),
    );
  }

  Widget _signupForm() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.60,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.05,
      ),
      child: Form(
        key: _signupFormKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16.0), // Adjust padding as needed
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildProfileImage(),
              CustomFormField(
                height: MediaQuery.of(context).size.height * 0.1,
                hintText: "Name",
                validationRegEx: NAME_VALIDATION_REGEX,
                onsaved: (value) {
                  setState(() {
                    name = value!;
                  });
                },
              ),
              CustomFormField(
                height: MediaQuery.of(context).size.height * 0.1,
                hintText: "Email",
                validationRegEx: EMAIL_VALIDATION_REGEX,
                onsaved: (value) {
                  setState(() {
                    email = value!;
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
                    password = value!;
                  });
                },
              ),
              _signupButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfileImage() {
    double radius = MediaQuery.of(context).size.width * 0.20;

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            child: CircleAvatar(
              radius: radius - 4, // Subtracting the border width
              backgroundImage: selectedimage != null
                  ? FileImage(selectedimage!)
                  : NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
              backgroundColor: Colors.transparent,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () async {
                File? file = await _mediaService.getImageFromGallery();

                if (file != null) {
                  setState(() {
                    selectedimage = file;
                  });
                }
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 4,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  color: Colors.green,
                ),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _signupButton() {
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
            setState(() {
              isloading = true;
            });

            try {
              if (_signupFormKey.currentState?.validate() ??
                  false && selectedimage != null) {
                _signupFormKey.currentState?.save();
                bool result = await _authService.signup(email, password);

                if (result) {
                  String? pfpURL = await _storageService.uploadUserPfp(
                      file: selectedimage!, uid: _authService.user!.uid);
                  if (pfpURL != null) {
                    await _databaseService.createUserProfile(
                        user_profile: Profile(
                      userid: _authService.user!.uid,
                      name: name,
                      email: email,
                      pfpURL: pfpURL,
                    ));
                    _alertService.showToast(
                      text: "User Registered Successfully!",
                      icon: Icons.check,
                    );
                    _navigationService.goBack();
                    _navigationService.pushReplacementNamed("/home");
                  } else {
                    throw Exception('Unable to upload image');
                  }
                }
              } else {
                throw Exception('Unable to register user!');
              }
            } catch (e) {
              _alertService.showToast(
                  text: "Failed to signup. $e", icon: Icons.error);
            }

            setState(() {
              isloading = false;
            });
          },
          color: Colors.transparent,
          elevation: 0, // Remove elevation to see the gradient
          child: const Text(
            "Signup",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginLink() {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text("Already have an account?"),
          GestureDetector(
            onTap: () {
              _navigationService.goBack();
            },
            child: const Text(
              "Login",
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
