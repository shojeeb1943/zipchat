//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zipchat/Configs/Dbkeys.dart';
import 'package:zipchat/Configs/Dbpaths.dart';
import 'package:zipchat/Configs/app_constants.dart';
import 'package:zipchat/Screens/Groups/GroupChatPage.dart';
import 'package:zipchat/Screens/call_history/callhistory.dart';
import 'package:zipchat/Screens/calling_screen/pickup_layout.dart';
import 'package:zipchat/Screens/chat_screen/chat.dart';
import 'package:zipchat/Services/Providers/SmartContactProviderWithLocalStoreData.dart';
import 'package:zipchat/Services/Providers/GroupChatProvider.dart';
import 'package:zipchat/Services/localization/language_constants.dart';
import 'package:zipchat/Models/DataModel.dart';
import 'package:zipchat/Utils/color_detector.dart';
import 'package:zipchat/Utils/theme_management.dart';
import 'package:zipchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectContactToShare extends StatefulWidget {
  const SelectContactToShare({
    required this.currentUserNo,
    required this.model,
    required this.prefs,
    required this.sharedFiles,
    this.sharedText,
  });
  final String? currentUserNo;
  final DataModel model;
  final SharedPreferences prefs;
  final List<SharedMediaFile> sharedFiles;
  final String? sharedText;

  @override
  _SelectContactToShareState createState() => new _SelectContactToShareState();
}

class _SelectContactToShareState extends State<SelectContactToShare>
    with AutomaticKeepAliveClientMixin {
  GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();
  Map<String?, String?>? contacts;
  bool isGroupsloading = true;
  var joinedGroupsList = [];
  @override
  bool get wantKeepAlive => true;

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void initState() {
    super.initState();
    fetchJoinedGroups();
  }

  fetchJoinedGroups() async {
    await FirebaseFirestore.instance
        .collection(DbPaths.collectiongroups)
        .where(Dbkeys.groupMEMBERSLIST, arrayContains: widget.currentUserNo)
        .orderBy(Dbkeys.groupCREATEDON, descending: true)
        .get()
        .then((groupsList) {
      if (groupsList.docs.length > 0) {
        groupsList.docs.forEach((group) {
          joinedGroupsList.add(group);
          if (groupsList.docs.last[Dbkeys.groupID] == group[Dbkeys.groupID]) {
            isGroupsloading = false;
          }
          setState(() {});
        });
      } else {
        isGroupsloading = false;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
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

  int currentUploadingIndex = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PickupLayout(
        prefs: widget.prefs,
        scaffold: zipchat.getNTPWrappedWidget(ScopedModel<DataModel>(
            model: widget.model,
            child: ScopedModelDescendant<DataModel>(
                builder: (context, child, model) {
              return Consumer<SmartContactProviderWithLocalStoreData>(
                  builder: (context, contactsProvider, _child) => Consumer<
                          List<GroupModel>>(
                      builder: (context, groupList, _child) => Scaffold(
                          key: _scaffold,
                          backgroundColor: Thm.isDarktheme(widget.prefs)
                              ? zipchatBACKGROUNDcolorDarkMode
                              : zipchatBACKGROUNDcolorLightMode,
                          appBar: AppBar(
                            elevation: 0.4,
                            titleSpacing: -5,
                            leading: IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(
                                Icons.arrow_back,
                                size: 24,
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
                            // leadingWidth: 40,
                            title: Text(
                              getTranslated(
                                  this.context, 'selectcontacttoshare'),
                              style: TextStyle(
                                fontSize: 18,
                                color: pickTextColorBasedOnBgColorAdvanced(
                                    Thm.isDarktheme(widget.prefs)
                                        ? zipchatAPPBARcolorDarkMode
                                        : zipchatAPPBARcolorLightMode),
                              ),
                            ),
                          ),
                          body: RefreshIndicator(
                            onRefresh: () {
                              return contactsProvider.fetchContacts(
                                  context,
                                  model,
                                  widget.currentUserNo!,
                                  widget.prefs,
                                  false);
                            },
                            child: contactsProvider
                                            .searchingcontactsindatabase ==
                                        true ||
                                    isGroupsloading == true
                                ? loading()
                                : contactsProvider
                                            .alreadyJoinedSavedUsersPhoneNameAsInServer
                                            .length ==
                                        0
                                    ? ListView(shrinkWrap: true, children: [
                                        Padding(
                                            padding: EdgeInsets.only(
                                                top: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    2.5),
                                            child: Center(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                      getTranslated(context,
                                                          'nocontacts'),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: zipchatGrey,
                                                      )),
                                                  SizedBox(
                                                    height: 40,
                                                  ),
                                                  IconButton(
                                                      onPressed: () async {
                                                        contactsProvider
                                                            .setIsLoading(true);
                                                        await contactsProvider
                                                            .fetchContacts(
                                                          context,
                                                          model,
                                                          widget.currentUserNo!,
                                                          widget.prefs,
                                                          true,
                                                          isRequestAgain: true,
                                                        )
                                                            .then((d) {
                                                          Future.delayed(
                                                              const Duration(
                                                                  milliseconds:
                                                                      500), () {
                                                            contactsProvider
                                                                .setIsLoading(
                                                                    false);
                                                          });
                                                        });
                                                        setState(() {});
                                                      },
                                                      icon: Icon(
                                                        Icons.refresh_rounded,
                                                        size: 40,
                                                        color:
                                                            zipchatPRIMARYcolor,
                                                      ))
                                                ],
                                              ),
                                            ))
                                      ])
                                    : ListView(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 10, 10, 10),
                                        physics: BouncingScrollPhysics(),
                                        shrinkWrap: true,
                                        children: [
                                          ListView.builder(
                                            padding: EdgeInsets.all(0),
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: joinedGroupsList.length,
                                            itemBuilder: (context, i) {
                                              return Column(
                                                children: [
                                                  ListTile(
                                                    leading: customCircleAvatarGroup(
                                                        url: joinedGroupsList
                                                                .contains(Dbkeys
                                                                    .groupPHOTOURL)
                                                            ? joinedGroupsList[
                                                                    i][
                                                                Dbkeys
                                                                    .groupPHOTOURL]
                                                            : '',
                                                        radius: 22),
                                                    title: Text(
                                                      joinedGroupsList[i]
                                                          [Dbkeys.groupNAME],
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: pickTextColorBasedOnBgColorAdvanced(Thm
                                                                .isDarktheme(
                                                                    widget
                                                                        .prefs)
                                                            ? zipchatBACKGROUNDcolorDarkMode
                                                            : zipchatBACKGROUNDcolorLightMode),
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    subtitle: Text(
                                                      '${joinedGroupsList[i][Dbkeys.groupMEMBERSLIST].length} ${getTranslated(context, 'participants')}',
                                                      style: TextStyle(
                                                        color: zipchatGrey,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      // for group
                                                      Navigator.pushReplacement(
                                                          context,
                                                          new MaterialPageRoute(
                                                              builder: (context) => new GroupChatPage(
                                                                  isCurrentUserMuted: joinedGroupsList[i].containsKey(Dbkeys.groupMUTEDMEMBERS)
                                                                      ? joinedGroupsList[i][Dbkeys.groupMUTEDMEMBERS].contains(widget
                                                                          .currentUserNo)
                                                                      : false,
                                                                  sharedText: widget
                                                                      .sharedText,
                                                                  sharedFiles: widget
                                                                      .sharedFiles,
                                                                  isSharingIntentForwarded:
                                                                      true,
                                                                  model: widget
                                                                      .model,
                                                                  prefs: widget
                                                                      .prefs,
                                                                  joinedTime: joinedGroupsList[i][
                                                                      '${widget.currentUserNo}-joinedOn'],
                                                                  currentUserno:
                                                                      widget.currentUserNo!,
                                                                  groupID: joinedGroupsList[i][Dbkeys.groupID])));
                                                    },
                                                  ),
                                                  Divider(
                                                    height: 2,
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                          ListView.builder(
                                            padding: EdgeInsets.all(0),
                                            shrinkWrap: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            itemCount: contactsProvider
                                                .alreadyJoinedSavedUsersPhoneNameAsInServer
                                                .length,
                                            itemBuilder: (context, idx) {
                                              String phone = contactsProvider
                                                  .alreadyJoinedSavedUsersPhoneNameAsInServer[
                                                      idx]
                                                  .phone;
                                              Widget? alreadyAddedUser;

                                              return alreadyAddedUser ??
                                                  FutureBuilder<LocalUserData?>(
                                                      future: contactsProvider
                                                          .fetchUserDataFromnLocalOrServer(
                                                              widget.prefs,
                                                              phone),
                                                      builder: (BuildContext
                                                              context,
                                                          AsyncSnapshot<
                                                                  LocalUserData?>
                                                              snapshot) {
                                                        if (snapshot.hasData) {
                                                          LocalUserData user =
                                                              snapshot.data!;
                                                          return Column(
                                                            children: [
                                                              ListTile(
                                                                leading:
                                                                    customCircleAvatar(
                                                                  url: user
                                                                      .photoURL,
                                                                  radius: 22.5,
                                                                ),
                                                                title: Text(
                                                                    user.name,
                                                                    style: TextStyle(
                                                                        color: pickTextColorBasedOnBgColorAdvanced(Thm.isDarktheme(widget.prefs)
                                                                            ? zipchatBACKGROUNDcolorDarkMode
                                                                            : zipchatBACKGROUNDcolorLightMode))),
                                                                subtitle: Text(
                                                                    phone,
                                                                    style: TextStyle(
                                                                        color:
                                                                            zipchatGrey)),
                                                                contentPadding:
                                                                    EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            10.0,
                                                                        vertical:
                                                                            0.0),
                                                                onTap: () {
                                                                  FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          DbPaths
                                                                              .collectionusers)
                                                                      .doc(user
                                                                          .id)
                                                                      .get()
                                                                      .then(
                                                                          (usr) {
                                                                    if (usr
                                                                        .exists) {
                                                                      if (usr.data()![Dbkeys
                                                                              .accountstatus] ==
                                                                          Dbkeys
                                                                              .sTATUSdeleted) {
                                                                        zipchat.toast(
                                                                            "User Not Available. Account Deleted !");
                                                                      } else {
                                                                        widget
                                                                            .model
                                                                            .addUser(usr);
                                                                        Navigator.pushReplacement(
                                                                            context,
                                                                            new MaterialPageRoute(builder: (context) => ChatScreen(sharedText: widget.sharedText, sharedFiles: widget.sharedFiles, isSharingIntentForwarded: true, prefs: widget.prefs, unread: 0, model: widget.model, currentUserNo: widget.currentUserNo, peerNo: user.id)));
                                                                      }
                                                                    } else {
                                                                      zipchat.toast(
                                                                          "User Not Available !");
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                              Divider(
                                                                height: 2,
                                                              )
                                                            ],
                                                          );
                                                        }
                                                        return SizedBox();
                                                      });
                                            },
                                          ),
                                        ],
                                      ),
                          ))));
            }))));
  }
}
