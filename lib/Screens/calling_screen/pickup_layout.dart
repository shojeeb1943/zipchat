//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zipchat/Screens/splash_screen/splash_screen.dart';
import 'package:zipchat/Services/Providers/Observer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zipchat/Models/call.dart';
import 'package:zipchat/Services/Providers/user_provider.dart';
import 'package:zipchat/Models/call_methods.dart';
import 'package:zipchat/Screens/calling_screen/pickup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;
  final SharedPreferences prefs;
  final CallMethods callMethods = CallMethods();

  PickupLayout({
    required this.scaffold,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final Observer observer = Provider.of<Observer>(context);

    return observer.isOngoingCall == true
        ? scaffold
        : (userProvider.getUser != null)
            ? StreamBuilder<DocumentSnapshot>(
                stream:
                    callMethods.callStream(phone: userProvider.getUser!.phone),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.data() != null) {
                    Call call = Call.fromMap(
                        snapshot.data!.data() as Map<dynamic, dynamic>);

                    if (!call.hasDialled!) {
                      return PickupScreen(
                        prefs: prefs,
                        call: call,
                        currentuseruid: userProvider.getUser!.phone,
                      );
                    }
                  }
                  return scaffold;
                },
              )
            : Splashscreen();
  }
}
