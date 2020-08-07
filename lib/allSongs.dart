import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';

 AudioPlayer audioPlayer = new AudioPlayer();
 final FlutterAudioQuery audioQuery = FlutterAudioQuery();

class AllSongs extends StatefulWidget {
  @override
  _AllSongsState createState() => _AllSongsState();
}

class _AllSongsState extends State<AllSongs> {
 List<FileSystemEntity> _files;
  List<FileSystemEntity> _songs = [];

  Duration _duration = new Duration();
  Duration _position = new Duration();
  Icon icon=Icon(Icons.play_arrow,);
  bool isPlaying=false;
  FileSystemEntity currSong;

  @override
  void initState() {
    super.initState();
    Directory dir = Directory('/storage/emulated/0/');
    String mp3Path = dir.toString();
    print(mp3Path);
    _files = dir.listSync(recursive: true, followLinks: false);
    for (FileSystemEntity entity in _files) {
      String path = entity.path;
      if (path.endsWith('.mp3')) _songs.add(entity);
    }
    print(_songs);
    print(_songs.length);
    initPlay();
    currSong=_songs[0];
  }

  initPlay() async {
    audioPlayer.durationHandler = (d) => setState(() {
          _duration = d;
        });
    audioPlayer.positionHandler = (p) => setState(() {
          _position = p;
        });
  }

  playMusic(FileSystemEntity url) {
    setState(() {
      audioPlayer.stop();
      audioPlayer.play(url.path, isLocal: true);
      isPlaying=true;
      icon=Icon(Icons.pause,);
      currSong=url;
    });
  }

  currSeek(int sec) {
    Duration newSeek = Duration(seconds: sec);
    audioPlayer.seek(newSeek);
  }

  stopMusic() {
    audioPlayer.stop();
    setState(() {
      isPlaying=false;
    });
  }
  pauseOrResumeMusic(){
    setState(() {
      if(isPlaying==true){
        audioPlayer.pause();
        icon=Icon(Icons.play_arrow,);
        isPlaying=false;
      }
      else{
        audioPlayer.resume();
        icon=Icon(Icons.pause,);
        isPlaying=true;
      }
    });
  }
   playPrev() {
    setState(() {
      int x=_songs.indexOf(currSong);
      if(x==0)
      x=_songs.length;
      FileSystemEntity url=_songs[x-1];
      audioPlayer.play(url.path, isLocal: true);
      isPlaying=true;
      icon=Icon(Icons.pause);
      currSong=_songs[x-1];
    });
  }
  playNext() {
    setState(() {
      int x=_songs.indexOf(currSong);
      if(x==_songs.length-1)
      x=-1;
      FileSystemEntity url=_songs[x+1];
      audioPlayer.play(url.path, isLocal: true);
      isPlaying=true;
      icon=Icon(Icons.pause);
      currSong=_songs[x+1];
      print(url.path);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: ListView.builder(
                itemCount: _songs.length,
                itemBuilder: (context, int index) {
                  return Container(
                    child: ListTile(
                      leading: Icon(
                        Icons.music_note,
                        color: Colors.green,
                      ),
                      title: new Text(_songs[index].path.split('/').last),
                      onTap: () => playMusic(_songs[index]),
                    ),
                  );
                }),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.lightBlue[100],
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top:8.0),
                    child: Text(currSong.path.split("/").last,softWrap: false,),
                  ),
                  Slider(
                      value: _position.inSeconds.toDouble(),
                      max: _duration.inSeconds.toDouble(),
                      min: 0.0,
                      onChanged: (double value) {
                        setState(() {
                          currSeek(value.toInt());
                          value = value;
                        });
                      }
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left:18.0),
                            child: Text(_position.inMinutes.toInt().toString()+":"+(_position.inSeconds.toInt()-_position.inMinutes.toInt()*60).toString().padLeft(2,'0')),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right:18.0),
                            child: Text(_duration.inMinutes.toInt().toString()+":"+(_duration.inSeconds.toInt()-_duration.inMinutes.toInt()*60).toString().padLeft(2,'0')),
                          )
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:<Widget>[
                        IconButton(icon: Icon(Icons.skip_previous,),onPressed: playPrev,),
                        IconButton(icon: icon,onPressed: pauseOrResumeMusic,),
                        IconButton(icon: Icon(Icons.skip_next,),onPressed: playNext,)
                      ]
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}