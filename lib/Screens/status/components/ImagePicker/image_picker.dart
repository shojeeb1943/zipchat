//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:io';
import 'package:zipchat/Configs/app_constants.dart';
import 'package:zipchat/Configs/optional_constants.dart';
import 'package:zipchat/Screens/status/components/VideoPicker/VideoPicker.dart';
import 'package:zipchat/Services/Providers/Observer.dart';
import 'package:zipchat/Services/localization/language_constants.dart';
import 'package:zipchat/Utils/color_detector.dart';
import 'package:zipchat/Utils/open_settings.dart';
import 'package:zipchat/Utils/theme_management.dart';
import 'package:zipchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatusImageEditor extends StatefulWidget {
  StatusImageEditor({
    Key? key,
    required this.title,
    required this.callback,
    required this.prefs,
  }) : super(key: key);

  final String title;
  final Function(String str, File file) callback;
  final SharedPreferences prefs;

  @override
  _StatusImageEditorState createState() => new _StatusImageEditorState();
}

class _StatusImageEditorState extends State<StatusImageEditor> {
  File? _imageFile;
  ImagePicker picker = ImagePicker();
  bool isLoading = false;
  String? error;
  @override
  void initState() {
    super.initState();
  }

  final TextEditingController textEditingController =
      new TextEditingController();
  void captureImage(ImageSource captureMode) async {
    final observer = Provider.of<Observer>(this.context, listen: false);
    error = null;
    try {
      XFile? pickedImage = await (picker.pickImage(source: captureMode));
      if (pickedImage != null) {
        _imageFile = File(pickedImage.path);

        if (_imageFile!.lengthSync() / 1000000 >
            observer.maxFileSizeAllowedInMB) {
          error =
              '${getTranslated(this.context, 'maxfilesize')} ${observer.maxFileSizeAllowedInMB}MB\n\n${getTranslated(this.context, 'selectedfilesize')} ${(_imageFile!.lengthSync() / 1000000).round()}MB';

          setState(() {
            _imageFile = null;
          });
        } else {
          setState(() {});
        }
      }
    } catch (e) {}
  }

  Widget _buildImage() {
    if (_imageFile != null) {
      return new Image.file(_imageFile!);
    } else {
      return new Text(getTranslated(context, 'takeimage'),
          style: new TextStyle(
            fontSize: 18.0,
            color: zipchatGrey,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return zipchat.getNTPWrappedWidget(WillPopScope(
      child: Scaffold(
        backgroundColor: Thm.isDarktheme(widget.prefs)
            ? zipchatBACKGROUNDcolorDarkMode
            : zipchatBACKGROUNDcolorLightMode,
        appBar: new AppBar(
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
            title: new Text(
              widget.title,
              style: TextStyle(
                fontSize: 18,
                color: pickTextColorBasedOnBgColorAdvanced(
                    Thm.isDarktheme(widget.prefs)
                        ? zipchatAPPBARcolorDarkMode
                        : zipchatAPPBARcolorLightMode),
              ),
            ),
            backgroundColor: Thm.isDarktheme(widget.prefs)
                ? zipchatAPPBARcolorDarkMode
                : zipchatAPPBARcolorLightMode,
            actions: _imageFile != null
                ? <Widget>[
                    IconButton(
                        icon: Icon(
                          Icons.check,
                          color: pickTextColorBasedOnBgColorAdvanced(
                              Thm.isDarktheme(widget.prefs)
                                  ? zipchatAPPBARcolorDarkMode
                                  : zipchatAPPBARcolorLightMode),
                        ),
                        onPressed: () {
                          widget.callback(
                              textEditingController.text.isEmpty
                                  ? ''
                                  : textEditingController.text,
                              _imageFile!);
                        }),
                    SizedBox(
                      width: 8.0,
                    )
                  ]
                : []),
        body: Stack(children: [
          new Column(children: [
            new Expanded(
                child: new Center(
                    child: error != null
                        ? fileSizeErrorWidget(error!)
                        : _buildImage())),
            _imageFile != null
                ? Container(
                    padding: EdgeInsets.all(12),
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.black,
                    child: Row(children: [
                      Flexible(
                        child: TextField(
                          maxLength: int.tryParse(
                              (MaxTextlettersInStatus / 1.7).toString()),
                          maxLines: null,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18.0, color: zipchatWhite),
                          controller: textEditingController,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              // width: 0.0 produces a thin "hairline" border
                              borderRadius: BorderRadius.circular(1),
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 1.5),
                            ),
                            hoverColor: Colors.transparent,
                            focusedBorder: OutlineInputBorder(
                              // width: 0.0 produces a thin "hairline" border
                              borderRadius: BorderRadius.circular(1),
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 1.5),
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(1),
                                borderSide:
                                    BorderSide(color: Colors.transparent)),
                            contentPadding: EdgeInsets.fromLTRB(7, 4, 7, 4),
                            hintText: getTranslated(context, 'typeacaption'),
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      ),
                    ]),
                  )
                : _buildButtons()
          ]),
          Positioned(
            child: isLoading
                ? Container(
                    child: Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                zipchatSECONDARYolor))),
                    color: pickTextColorBasedOnBgColorAdvanced(
                            !Thm.isDarktheme(widget.prefs)
                                ? zipchatCONTAINERboxColorDarkMode
                                : zipchatCONTAINERboxColorLightMode)
                        .withOpacity(0.6),
                  )
                : Container(),
          )
        ]),
      ),
      onWillPop: () => Future.value(!isLoading),
    ));
  }

  Widget _buildButtons() {
    return new ConstrainedBox(
        constraints: BoxConstraints.expand(height: 80.0),
        child: new Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildActionButton(new Key('retake'), Icons.photo_library, () {
                zipchat
                    .checkAndRequestPermission(Permission.storage)
                    .then((res) {
                  if (res) {
                    captureImage(ImageSource.gallery);
                  } else {
                    zipchat.showRationale(getTranslated(context, 'pgi'));
                    Navigator.pushReplacement(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => OpenSettings(
                                  prefs: widget.prefs,
                                )));
                  }
                });
              }),
              _buildActionButton(new Key('upload'), Icons.photo_camera, () {
                zipchat
                    .checkAndRequestPermission(Permission.camera)
                    .then((res) {
                  if (res) {
                    captureImage(ImageSource.camera);
                  } else {
                    getTranslated(context, 'pci');
                    Navigator.pushReplacement(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => OpenSettings(
                                  prefs: widget.prefs,
                                )));
                  }
                });
              }),
            ]));
  }

  Widget _buildActionButton(Key key, IconData icon, Function onPressed) {
    return new Expanded(
      child: new IconButton(
          key: key,
          icon: Icon(icon, size: 30.0),
          color: zipchatPRIMARYcolor,
          onPressed: onPressed as void Function()?),
    );
  }
}
