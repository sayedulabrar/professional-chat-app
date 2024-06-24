import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../service/notification_service.dart';
import '/service/auth_service.dart';
import '/utils/chat_page.dart';
import '../models/profile.dart';
import '../widget/chat_tile.dart';
import '../service/alert_service.dart';
import '../service/database_service.dart';
import '../service/navigation_service.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;
  late PushNotificationService _pushNotificationService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
    _pushNotificationService = _getIt.get<PushNotificationService>();
    setupFCM();
  }

  void setupFCM() async {
    await _pushNotificationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            color: Colors.red, // Or any desired color
            onPressed: () async {
              bool result = await _authService.logout();
              if (result) {
                _alertService.showToast(
                  text: 'Successfully logout!',
                  icon: Icons.check,
                );
                _navigationService.pushReplacementNamed('/login');
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
        child: _chatsList(),
      ),
    );
  }

  Widget _chatsList() {
    return StreamBuilder(
      // Replace List<String> with actual user data type
      stream: _databaseService.getUserProfiles(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text("Unable to load data."),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          final users =
              snapshot.data!.docs; // Assuming data is a list of usernames

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              Profile userProfile = users[index].data();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ChatTile(
                  userProfile: userProfile,
                  onTap: () async {
                    final chatExists = await _databaseService.checkChatExists(
                        _authService.user!.uid, userProfile.userid);
                    if (!chatExists) {
                      await _databaseService.createNewChat(
                          _authService.user!.uid, userProfile.userid);
                    }
                    _navigationService
                        .push(MaterialPageRoute(builder: (context) {
                      return ChatPage(chatUser: userProfile);
                    }));
                  },
                ),
              );
            },
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
