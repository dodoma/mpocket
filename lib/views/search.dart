import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mpocket/common/global.dart';
import 'package:mpocket/ffi/libmoc.dart' as libmoc;
import 'package:mpocket/models/imlocal.dart';
import 'package:mpocket/models/imsource.dart';
import 'package:mpocket/views/music_album_screen.dart';
import 'package:mpocket/views/music_artist_screen.dart';
import 'package:provider/provider.dart';

const double kAlbumTileWidth = 82.0;
const double kAlbumTileHeight = 82.0 + 18.0;

const double kArtistTileWidth = 78.0;
const double kArtistTileHeight = 78.0 + 18.0;

@JsonSerializable()
class MediaEntity {
  MediaEntity();

  late int type;      /* 0 artist, 1 album, 2 track, 3 filename */
  late String cover;
  late String? artist;
  late String? album;
  late String? title;
  late String? trackid;

  factory MediaEntity.fromJson(Map<String, dynamic> json) => _$MediaEntityFromJson(json);
  Map<String, dynamic> toJson() => _$MediaEntityToJson(this);
}

MediaEntity _$MediaEntityFromJson(Map<String, dynamic> json) =>
    MediaEntity()
      ..type = json['type'] as int
      ..cover = json['cover'] as String
      ..artist = json['artist'] as String?
      ..album = json['album'] as String?
      ..title = json['title'] as String?
      ..trackid = json['trackid'] as String?;

Map<String, dynamic> _$MediaEntityToJson(MediaEntity instance) =>
    <String, dynamic>{
      'type': instance.type,
      'cover': instance.cover,
      'artist': instance.artist,
      'album': instance.album,
      'title': instance.title,
      'trackid': instance.trackid,
    };

class ArtistTile extends StatelessWidget {
  final String name;
  final String head;
  const ArtistTile({super.key, required this.name, required this.head});

  @override
  Widget build(BuildContext context) {
    ImageProvider headimg = AssetImage('assets/image/artist_cover.jpg');
    try {
      File file = File(head);
      if (file.existsSync()) {
        headimg = FileImage(file);
      }
    } catch (e) {
      //
    }
    return InkWell(
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: headimg,
            radius: 35,
          ),
          const Gap(5),
          Container(
            width: 100,
            alignment: Alignment.center,
            child: Text(
              overflow: TextOverflow.ellipsis, // 溢出时显示省略号
              maxLines: 1, // 限制文本行数为1
              name
            )
          ),
        ],
      ),
      onTap: () {
        print('clicked ${name}');
        //context.push('/user');
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => MusicArtistScreen(artist: name)
        ));
      },
    );
  }
}

class AlbumTile extends StatelessWidget {
  final String artist;  
  final String title;
  final String cover;
  const AlbumTile({super.key, required this.artist, required this.title, required this.cover});

  @override
  Widget build(BuildContext context) {
    Image headimg = Image.asset('assets/image/artist_cover.jpg', height: 72,);
    try {
      File file = File(cover);
      if (file.existsSync()) {
        headimg = Image.file(file, height: 72,);
      }
    } catch (e) {
      //
    }
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Column(
          children: [
            headimg,
            const Gap(5),
            Container(
              width: 100,
              alignment: Alignment.center,
              child: Text(
                overflow: TextOverflow.ellipsis, // 溢出时显示省略号
                maxLines: 1, // 限制文本行数为1
                title
              )
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => MusicAlbumScreen(artist: artist, album: title,)
        ));
      },
    );
  }
}

class TrackTile extends StatelessWidget {
  final String id;
  final String title;
  final String cover;
  const TrackTile({super.key, required this.id, required this.title, required this.cover});

  @override
  Widget build(BuildContext context) {
    Image headimg = Image.asset('assets/image/artist_cover.jpg', height: 42);
    try {
      File file = File(cover);
      if (file.existsSync()) {
        headimg = Image.file(file, height: 42,);
      }
    } catch (e) {
      //
    }
    return InkWell(
      child: ListTile(
        leading: headimg,
        title: Text(title, overflow: TextOverflow.ellipsis, maxLines: 1),
        contentPadding: EdgeInsets.all(0),
        trailing: IconButton(onPressed: (){
          context.read<IMlocal>().addToPlayList(id);            
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('下一首播放'),
            duration: Duration(seconds: 2)
          ));
        }, icon: Icon(size: 24, Icons.add)), 
      ),     
      onTap: () async {
        if (Global.profile.phonePlay) await context.read<IMlocal>().playSingle(context, id, true);
        else libmoc.mnetPlayID(Global.profile.msourceID, id);
        context.read<IMbanner>().turnOnBanner();
      },
    );
  }
}

class SearchTab extends StatefulWidget {
  final String query;
  const SearchTab({super.key, required this.query});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  late List<MediaEntity> searchResult;
  List<Widget> artists = <Widget>[];
  List<Widget> albums = <Widget>[];
  List<Widget> tracks = <Widget>[];

  bool _isLoading = true;

  String emot = '''
[
  {"type": 0, "cover": "", "artist": "BlackPink"},
  {"type": 0, "cover": "", "artist": "张三"},
  {"type": 0, "cover": "", "artist": "牛逼专辑"},
  {"type": 0, "cover": "", "artist": "一千个伤心的理由", "trackid": "234dwer"},
  {"type": 0, "cover": "", "artist": "One", "trackid": "39d9e"},

  {"type": 1, "cover": "", "artist": "BlackPink", "title": "一千个伤心的理由"},
  {"type": 1, "cover": "", "artist": "张三", "title": "一千个伤心的理由"},
  {"type": 1, "cover": "", "artist": "牛逼专辑", "title": "一千个伤心的理由"},
  {"type": 1, "cover": "", "artist": "一千个伤心的理由", "title": "一千个伤心的理由"},
  {"type": 1, "cover": "", "artist": "One", "title": "一千个伤心的理由"},

  {"type": 2, "cover": "", "trackid": "aaabbf323", "title": "BlackPink"},
  {"type": 2, "cover": "", "trackid": "aaabbf323", "title": "张三"},
  {"type": 2, "cover": "", "trackid": "aaabbf323", "title": "牛逼专辑牛逼专辑牛逼专辑牛逼专辑牛逼专辑牛逼专辑"},
  {"type": 2, "cover": "", "trackid": "aaabbf323", "title": "一千个伤心的理由", "trackid": "234dwer"},
  {"type": 2, "cover": "", "trackid": "aaabbf323", "title": "One", "trackid": "39d9e"},

  {"type": 3, "cover": "", "trackid": "aaabbf323", "title": "BlackPink"},
  {"type": 3, "cover": "", "trackid": "aaabbf323", "title": "张三"},
  {"type": 3, "cover": "", "trackid": "aaabbf323", "title": "牛逼专辑"},
  {"type": 3, "cover": "", "trackid": "aaabbf323", "title": "一千个伤心的理由", "trackid": "234dwer"},
  {"type": 3, "cover": "", "trackid": "aaabbf323", "title": "One", "trackid": "39d9e"}
]
''';

  @override
  void initState() {
    String emos = libmoc.omusicSearch(Global.profile.msourceID, widget.query);
    if (emos.isNotEmpty) {
      List<dynamic> jsonData = jsonDecode(emos);
      searchResult = jsonData.map((obj) => MediaEntity.fromJson(obj)).toList();
      searchResult.forEach((media) {
        if (media.type == 0) artists.add(ArtistTile(name: media.artist!, head: media.cover));
        else if (media.type == 1) albums.add(AlbumTile(artist: media.artist!, title: media.title!, cover: media.cover));
        else if (media.type == 2 || media.type == 3) tracks.add(TrackTile(id: media.trackid!, title: media.title!, cover: media.cover));
      });
    }
    _isLoading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
      ? CircularProgressIndicator()
      : Container(
          padding: EdgeInsets.all(15),
          child: artists.isNotEmpty || albums.isNotEmpty || tracks.isNotEmpty
            ? ListView(
              children: <Widget>[
                if (artists.isNotEmpty)
                  Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text('艺术家', style: TextStyle(fontWeight: FontWeight.w700))
                          )
                        ]
                      ),
                      Container(
                        height: kArtistTileHeight + 10.0,
                        width: MediaQuery.of(context).size.width,
                        child: ListView(
                          padding: EdgeInsets.only(
                            left: 16.0,
                            top: 2.0,
                            bottom: 8.0,
                          ),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          children: artists,
                        ),
                      ),
                    ],
                  ),

                if (albums.isNotEmpty)
                  Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text('专辑', style: TextStyle(fontWeight: FontWeight.w700))
                          )
                        ]
                      ),
                      Container(
                        height: kAlbumTileHeight + 10.0,
                        width: MediaQuery.of(context).size.width,
                        child: ListView(
                          padding: EdgeInsets.only(
                            left: 16.0,
                            top: 2.0,
                            bottom: 8.0,
                          ),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          children: albums,
                        ),
                      ),
                    ],
                  ),

                if (tracks.isNotEmpty)
                  Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text('曲目', style: TextStyle(fontWeight: FontWeight.w700))
                          )
                        ]
                      ),
                      Container(
                        height: 400,
                        child: ListView(
                          padding: EdgeInsets.only(
                            left: 16.0,
                            top: 2.0,
                            bottom: 8.0,
                          ),
                          children: tracks,
                        ),
                      ),
                    ],
                  ),
              ],
            )
            : Center(
              child: Text('搜索结果为空，尝试切换媒体库？'),
            )         
        );
  }
}