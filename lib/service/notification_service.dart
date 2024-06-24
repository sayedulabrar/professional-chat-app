import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:get_it/get_it.dart';
import '../models/profile.dart';
import 'auth_service.dart';
import 'database_service.dart';

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetIt _getIt = GetIt.instance;
  late DatabaseService _databaseService;
  late AuthService _authService;

  PushNotificationService() {
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
  }

  Future<void> initialize() async {
    // Request permission for iOS
    // Request permissions for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // // For apple platforms, ensure the APNS token is available
    // final apnsToken = await _firebaseMessaging.getAPNSToken();
    // if (apnsToken != null) {
    //   // APNS token is available
    // }

    // Get the token
    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");

    // Save the token to your database or send it to your server
    if (token != null) {
      await saveToken(token);
    } else {
      print("TOKEN NOT RECIVED.SADDDDDDDD");
    }

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print("FCM Token Refreshed: $newToken");
      await saveToken(newToken);
    }).onError((err) {
      print("Error getting token: $err");
    });
  }

  Future<void> saveToken(String token) async {
    // Save the token in Firestore or another database

    await _firestore.collection('tokens').doc(_authService.user!.uid).set({
      'is_online': true,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'deviceToken': token,
    });
  }

  Future<String?> getToken(String userId) async {
    DocumentSnapshot snapshot =
        await _firestore.collection('tokens').doc(userId).get();
    return snapshot['deviceToken'];
  }

  Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "chat-app-9f719",
      "private_key_id": "0768b466fd4d2c8db490b4ae809d73c3886d10c1",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEuwIBADANBgkqhkiG9w0BAQEFAASCBKUwggShAgEAAoIBAQCe8tsCwJG2Hvef\nQ19/xuzPhTiCiyDQatnT/Q5iwoJ3KZcJruDi7o2SAN5bf82K5YeXsJxr1vexAxdQ\nLzQgGkbzqFjL0feUZnlOa23fJ1xeCHqYtKxaVrXj5Svpm0Lv4eRwevrDEXMc2x2o\nih6QSdOJMNRJUOICQPiFj8G4Ynx1w2iQmna3Uh2zgBmeZAlyU8DC0t0nX2+YYYdN\nMsCsoyp5Rv5MrBtOX3hAtDpFEb8B5grS1HGfUGRs7KsdikoQAqYyILlzgnp4gQGt\nN4GQFAGgQGtM+i3ZftF0g/0x5JCMwERe/teC9CPrh37VTyJeJkys/28SBCy204gc\nJqpKNg0LAgMBAAECgf8T4hBSu59+nIWmbKikEDgt1cujfKuL4K1S0UK4YRZ3AlU9\n5vGcTQpQMy0jponY3D8T2RYyBbgnEQUQal1RvxxRzD1PWitzm7+EwIoEEPqz1Mlo\n1ufdD8r6KueilGHde4LtUivPOwQlPICj8BDisqKlEupvHNm7GRxfBn4i4c1/HkxD\n6YeTXWisVHiAoWgCsFEoh05V4ukBcfO4rptYk20pbi2KkRv56VCB28Y4ejTGSHvJ\n5ITnIAJYhLz0o9iJfWfpbDg9C1YwX3sSHASC9IQwib5oONKqX9GI44KlgSqjBk+p\nHWgewa1TE2RySGrjtEp9nIKUsSYQMgHgT4TBCaUCgYEA1ASfRYX3spM65P1dFWC8\n/ZOyWqmH/yB3rzAL6bIoxDlTtMu8/ex3/QFwxenGlWG2bQVVrVv9oxScLMx2okaB\n+5jxouR0w7e19P06mxVxJZ+OuNR/ldQF66ysD4O0lfbvYubquQfSCHTamQzYY3aD\nSeWzMu8+5eotHLy4gAhqvr0CgYEAv+vxaXA+8ZQtmI/Zbnf9luqy+NMYqdxswINu\nckHqbCc1qaipM060n0y6EPDJv+Es+3HKuVX3JYED4R3mOtUYDr0x1/uHHiTBgjF0\nrPuFImlS30G+/QlqXpvuyf8mn864XNj6paSnP+5HPPgrUZt7HumTy3GqssW2agoX\n1TtA+2cCgYBFuCtj4lT8vRud1483i3M6c8ovtBYLmHKjAkq4k6SCOlPDXUgNvCgM\n499gxapOzy39FccB1gFHEmz08luEq2jtAnNbXILlJVFJecg+3UMy2xBEyWQXMfys\nbkC6bVYCBozb2hGPvPmdXEfSEn5J3tv3ffh6pF/rnSEulQSa3am0hQKBgAIYBeM7\nmUQzdKfkcd/VqUubNeanDu7Te9BB3tOaSn9xkhFOyMHJiwjt4l3K8riIMWBw5mBN\nQswC81Lia5+asY9/muqbUOcQSZgtB/PXLqWodoH/CqFiF+n+U4WapgY6UCKbL2jd\nOgHljJtqrbZPNvGoZLdkfxNCOvI/N/FYmyXjAoGBAJXBIDSL1z4CsZD3Ib6z0QMG\ndLEj7OKoGAgWGKhi5OaJAtZjTcE5bAyEneu776vnHxadJ27i850UtbU4n/uJpYI8\n/QP2ZsI23dpMcFWbdC+mtG4yXCj+mKkcr/eQw6YPlq5Q/a4xkLX3/uG+VpE5zCWw\nxQQb4tfDjamV/kgqk16I\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-ohwog@chat-app-9f719.iam.gserviceaccount.com",
      "client_id": "111323363245726106573",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-ohwog%40chat-app-9f719.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging",
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

// get the access token
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    client.close();

    return credentials.accessToken.data;
  }

  Future<bool> status(String userId) async {
    DocumentSnapshot snapshot =
        await _firestore.collection('tokens').doc(userId).get();
    // return snapshot['is_online'] ?? false;
    return false;
  }

  Future<void> sendNotificationToSelectedDriver(String deviceToken) async {
    Profile? myself = await _databaseService.fetchPersonalProfile();
    String myname = myself!.name;

    final String serverAccessTokenkey = await getAccessToken();

    String endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/chat-app-9f719/messages:send';

    final Map<String, dynamic> message = {
      "message": {
        "token": deviceToken,
        'notification': {
          "title": "New message from $myname",
          'body': "Please check your message"
        },
        'data': {'': ''}
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAccessTokenkey',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('FCM message sent successfully');
    } else {
      print('Failed to send FCM message: ${response.statusCode}');
      print(response.body);
    }
  }
}
