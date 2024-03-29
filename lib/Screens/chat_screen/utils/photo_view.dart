//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************
import 'package:zipchat/Configs/app_constants.dart';
import 'package:zipchat/Utils/utils.dart';
import 'package:zipchat/widgets/DownloadManager/save_image_videos_in_gallery.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhotoViewWrapper extends StatelessWidget {
  PhotoViewWrapper(
      {this.imageProvider,
      this.message,
      this.loadingChild,
      this.backgroundDecoration,
      this.minScale,
      this.maxScale,
      required this.keyloader,
      required this.prefs,
      required this.imageUrl,
      required this.tag});

  final String tag;
  final String? message;
  final GlobalKey keyloader;
  final SharedPreferences prefs;
  final ImageProvider? imageProvider;
  final Widget? loadingChild;
  final Decoration? backgroundDecoration;
  final dynamic minScale;
  final String imageUrl;
  final dynamic maxScale;

  final GlobalKey<ScaffoldState> _scaffoldd = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return zipchat.getNTPWrappedWidget(Scaffold(
        backgroundColor: Colors.black,
        key: _scaffoldd,
        appBar: AppBar(
          elevation: 0.4,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back,
              size: 24,
              color: zipchatWhite,
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "dfs32231t834",
          backgroundColor: zipchatSECONDARYolor,
          onPressed: () async {
            GalleryDownloader.saveNetworkImage(
              context,
              imageUrl,
              false,
              "",
              keyloader,
              prefs,
            );
          },
          child: Icon(
            Icons.file_download,
          ),
        ),
        body: Container(
            color: Colors.black,
            constraints: BoxConstraints.expand(
              height: MediaQuery.of(context).size.height,
            ),
            child: PhotoView(
              loadingBuilder: (BuildContext context, var image) {
                return loadingChild ??
                    Center(
                      child: Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              zipchatSECONDARYolor),
                        ),
                      ),
                    );
              },
              imageProvider: imageProvider,
              backgroundDecoration: backgroundDecoration as BoxDecoration?,
              minScale: minScale,
              maxScale: maxScale,
            ))));
  }
}
