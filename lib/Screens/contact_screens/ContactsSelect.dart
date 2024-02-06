//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:contacts_service/contacts_service.dart';
import 'package:zipchat/Configs/Dbkeys.dart';
import 'package:zipchat/Configs/app_constants.dart';
import 'package:zipchat/Screens/calling_screen/pickup_layout.dart';
import 'package:zipchat/Services/Providers/SmartContactProviderWithLocalStoreData.dart';
import 'package:zipchat/Services/localization/language_constants.dart';
import 'package:zipchat/Models/DataModel.dart';
import 'package:zipchat/Utils/color_detector.dart';
import 'package:zipchat/Utils/open_settings.dart';
import 'package:zipchat/Utils/theme_management.dart';
import 'package:zipchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:localstorage/localstorage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactsSelect extends StatefulWidget {
  const ContactsSelect({
    required this.currentUserNo,
    required this.model,
    required this.biometricEnabled,
    required this.prefs,
    required this.onSelect,
  });
  final String? currentUserNo;
  final DataModel? model;
  final SharedPreferences prefs;
  final bool biometricEnabled;
  final Function(String? contactname, String contactphone) onSelect;

  @override
  _ContactsSelectState createState() => new _ContactsSelectState();
}

class _ContactsSelectState extends State<ContactsSelect>
    with AutomaticKeepAliveClientMixin {
  Map<String?, String?>? contacts;
  Map<String?, String?> _filtered = new Map<String, String>();

  @override
  bool get wantKeepAlive => true;

  final TextEditingController _filter = new TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _filter.dispose();
  }

  loading() {
    return Stack(children: [
      Container(
        child: Center(
            child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(zipchatSECONDARYolor),
        )),
      )
    ]);
  }

  @override
  initState() {
    super.initState();
    getContacts();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _appBarTitle = new Text(
        getTranslated(context, 'selectcontact'),
        style: TextStyle(
          fontSize: 18,
          color: pickTextColorBasedOnBgColorAdvanced(
              Thm.isDarktheme(widget.prefs)
                  ? zipchatAPPBARcolorDarkMode
                  : zipchatAPPBARcolorLightMode),
        ),
      );
    });
  }

  String? getNormalizedNumber(String number) {
    if (number.isEmpty) {
      return null;
    }

    return number.replaceAll(new RegExp('[^0-9+]'), '');
  }

  _isHidden(String? phoneNo) {
    Map<String, dynamic> _currentUser = widget.model!.currentUser!;
    return _currentUser[Dbkeys.hidden] != null &&
        _currentUser[Dbkeys.hidden].contains(phoneNo);
  }

  Future<Map<String?, String?>> getContacts({bool refresh = false}) async {
    Completer<Map<String?, String?>> completer =
        new Completer<Map<String?, String?>>();

    LocalStorage storage = LocalStorage(Dbkeys.cachedContacts);

    Map<String?, String?> _cachedContacts = {};

    completer.future.then((c) {
      c.removeWhere((key, val) => _isHidden(key));
      if (mounted) {
        setState(() {
          this.contacts = this._filtered = c;
        });
      }
    });

    zipchat.checkAndRequestPermission(Permission.contacts).then((res) {
      if (res) {
        storage.ready.then((ready) async {
          if (ready) {
            String? getNormalizedNumber(String? number) {
              if (number == null) return null;
              return number.replaceAll(new RegExp('[^0-9+]'), '');
            }

            ContactsService.getContacts(withThumbnails: false)
                .then((Iterable<Contact> contacts) async {
              contacts.where((c) => c.phones!.isNotEmpty).forEach((Contact p) {
                if (p.displayName != null && p.phones!.isNotEmpty) {
                  List<String?> numbers = p.phones!
                      .map((number) {
                        String? _phone = getNormalizedNumber(number.value);

                        return _phone;
                      })
                      .toList()
                      .where((s) => s != null)
                      .toList();

                  numbers.forEach((number) {
                    _cachedContacts[number] = p.displayName;
                    setState(() {});
                  });
                  setState(() {});
                }
              });

              // await storage.setItem(Dbkeys.cachedContacts, _cachedContacts);
              completer.complete(_cachedContacts);
            });
          }
          // }
        });
      } else {
        zipchat.showRationale(getTranslated(context, 'perm_contact'));
        Navigator.pushReplacement(
            context,
            new MaterialPageRoute(
                builder: (context) => OpenSettings(
                      permtype: 'contact',
                      prefs: widget.prefs,
                    )));
      }
    }).catchError((onError) {
      zipchat.showRationale('Error occured: $onError');
    });

    return completer.future;
  }

  Widget _appBarTitle = Text('');

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PickupLayout(
        prefs: widget.prefs,
        scaffold: zipchat.getNTPWrappedWidget(ScopedModel<DataModel>(
            model: widget.model!,
            child: ScopedModelDescendant<DataModel>(
                builder: (context, child, model) {
              return Consumer<SmartContactProviderWithLocalStoreData>(
                  builder: (context, contactsProvider, _child) => Scaffold(
                      backgroundColor: Thm.isDarktheme(widget.prefs)
                          ? zipchatBACKGROUNDcolorDarkMode
                          : zipchatBACKGROUNDcolorLightMode,
                      appBar: AppBar(
                        elevation: 0.4,
                        leading: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.keyboard_arrow_left,
                            size: 30,
                            color: pickTextColorBasedOnBgColorAdvanced(
                                Thm.isDarktheme(widget.prefs)
                                    ? zipchatAPPBARcolorDarkMode
                                    : zipchatAPPBARcolorLightMode),
                          ),
                        ),
                        backgroundColor: Thm.isDarktheme(widget.prefs)
                            ? zipchatAPPBARcolorDarkMode
                            : zipchatAPPBARcolorLightMode,
                        centerTitle: false,
                        title: _appBarTitle,
                        actions: <Widget>[
                          // IconButton(
                          //   icon: _searchIcon,
                          //   onPressed: _searchPressed,
                          // )
                        ],
                      ),
                      body: contacts == null
                          ? loading()
                          : RefreshIndicator(
                              onRefresh: () {
                                return getContacts(refresh: true);
                              },
                              child: _filtered.isEmpty
                                  ? ListView(children: [
                                      Padding(
                                          padding: EdgeInsets.only(
                                              top: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  2.5),
                                          child: Center(
                                            child: Text(
                                                getTranslated(
                                                    context, 'nosearchresult'),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: zipchatBlack,
                                                )),
                                          ))
                                    ])
                                  : ListView.builder(
                                      padding: EdgeInsets.all(10),
                                      itemCount: _filtered.length,
                                      itemBuilder: (context, idx) {
                                        MapEntry user =
                                            _filtered.entries.elementAt(idx);
                                        String phone = user.key;
                                        return FutureBuilder<LocalUserData?>(
                                            future: contactsProvider
                                                .fetchUserDataFromnLocalOrServer(
                                                    widget.prefs, phone),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<LocalUserData?>
                                                    snapshot) {
                                              if (snapshot.hasData &&
                                                  snapshot.data != null) {
                                                var userDoc = snapshot.data!;
                                                return ListTile(
                                                  leading: CircleAvatar(
                                                      backgroundColor:
                                                          zipchatSECONDARYolor,
                                                      radius: 22.5,
                                                      child: Text(
                                                        zipchat.getInitials(
                                                            userDoc.name),
                                                        style: TextStyle(
                                                            color:
                                                                zipchatWhite),
                                                      )),
                                                  title: Text(userDoc.name,
                                                      style: TextStyle(
                                                          color: pickTextColorBasedOnBgColorAdvanced(Thm
                                                                  .isDarktheme(
                                                                      widget
                                                                          .prefs)
                                                              ? zipchatBACKGROUNDcolorDarkMode
                                                              : zipchatBACKGROUNDcolorLightMode))),
                                                  subtitle: Text(phone,
                                                      style: TextStyle(
                                                          color: zipchatGrey)),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 10.0,
                                                          vertical: 0.0),
                                                  onTap: () {
                                                    Navigator.of(context).pop();
                                                    widget.onSelect(
                                                        user.value, phone);
                                                  },
                                                );
                                              }
                                              return ListTile(
                                                leading: CircleAvatar(
                                                    backgroundColor:
                                                        zipchatSECONDARYolor,
                                                    radius: 22.5,
                                                    child: Text(
                                                      zipchat.getInitials(
                                                          user.value),
                                                      style: TextStyle(
                                                          color: zipchatWhite),
                                                    )),
                                                title: Text(user.value,
                                                    style: TextStyle(
                                                        color: pickTextColorBasedOnBgColorAdvanced(Thm
                                                                .isDarktheme(
                                                                    widget
                                                                        .prefs)
                                                            ? zipchatBACKGROUNDcolorDarkMode
                                                            : zipchatBACKGROUNDcolorLightMode))),
                                                subtitle: Text(phone,
                                                    style: TextStyle(
                                                        color: zipchatGrey)),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 0.0),
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                  widget.onSelect(
                                                      user.value, phone);
                                                },
                                              );
                                            });
                                      },
                                    ))));
            }))));
  }
}
