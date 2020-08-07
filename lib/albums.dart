import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:PlayMusic/allSongs.dart';

class Albums extends StatefulWidget {
  @override
  _AlbumsState createState() => _AlbumsState();
}

class _AlbumsState extends State<Albums> {
  List<ArtistInfo> artists;
  List<AlbumInfo> albumList;

  @override
  void initState() {
    super.initState();
    getAllAlbums();
  }

  getAllAlbums() async {
    final FlutterAudioQuery audioQuery = FlutterAudioQuery();
    albumList = await audioQuery.getAlbums();
    artists = await audioQuery.getArtists(); // returns all artists available
    /// getting all albums available from a specific artist
    List<AlbumInfo> albums =
        await audioQuery.getAlbumsFromArtist(artist: artists[2].name);
    setState(() {});
    albums.forEach((artistAlbum) {
      print(artistAlbum); //print all album property values
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 6,
                  child: albumList==null?Center(child:CircularProgressIndicator()):ListView.builder(
                itemCount: albumList.length,
                itemBuilder: (context, int index) {
                  return Container(
                    child: ListTile(
                      leading: Icon(
                        Icons.music_note,
                        color: Colors.green,
                      ),
                      title: Text(albumList[index].title),
                      onTap: ()=>Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context) => AlbumSongs(
                          totalAlbumSongs: albumList[index].numberOfSongs,
                          albumId: albumList[index].id,
                        ),
                      )),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}


class AlbumSongs extends StatefulWidget {
  final totalAlbumSongs;
  final albumId;
  AlbumSongs({this.totalAlbumSongs,this.albumId});
  @override
  _AlbumSongsState createState() => _AlbumSongsState();
}

class _AlbumSongsState extends State<AlbumSongs> {

  List<SongInfo> albumSongs;
  Duration _duration = new Duration();
  Duration _position = new Duration();
  Icon icon=Icon(Icons.play_arrow,);
  bool isPlaying=false;
  SongInfo currAlbumSong;

  @override
  void initState() {
    super.initState();
    initAlbum();
    initAlubumPlay();
  }

  initAlbum() async{
    albumSongs=await audioQuery.getSongsFromAlbum(albumId: widget.albumId);
    currAlbumSong=albumSongs[0];
    setState(() {});
    albumSongs.forEach((element) {print(element);});
  }

  initAlubumPlay() async {
    audioPlayer.durationHandler = (d) => setState(() {
          _duration = d;
        });
    audioPlayer.positionHandler = (p) => setState(() {
          _position = p;
        });
  }

  playAlbumMusic(SongInfo url) {
    setState(() {
      audioPlayer.stop();
      audioPlayer.play(url.filePath, isLocal: true);
      isPlaying=true;
      icon=Icon(Icons.pause,);
      currAlbumSong=url;
    });
  }

 currSeek(int sec) {
    Duration newSeek = Duration(seconds: sec);
    audioPlayer.seek(newSeek);
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
      int x=albumSongs.indexOf(currAlbumSong);
      if(x==0)
      x=albumSongs.length;
      SongInfo url=albumSongs[x-1];
      audioPlayer.play(url.filePath, isLocal: true);
      isPlaying=true;
      icon=Icon(Icons.pause);
      currAlbumSong=albumSongs[x-1];
    });
  }
  playNext() {
    setState(() {
      int x=albumSongs.indexOf(currAlbumSong);
      if(x==albumSongs.length-1)
      x=-1;
      SongInfo url=albumSongs[x+1];
      audioPlayer.play(url.filePath, isLocal: true);
      isPlaying=true;
      icon=Icon(Icons.pause);
      currAlbumSong=albumSongs[x+1];
      print(url.filePath);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Play Music"),
        centerTitle: true,
      ),
      body:  Column(
        children: <Widget>[
          Expanded(
            flex: 6,
                  child: ListView.builder(
                      itemCount: int.parse(widget.totalAlbumSongs),
                      itemBuilder: (context, int index) {
                        return ListTile(
                          leading: Icon(
                            Icons.music_note,
                            color: Colors.green,
                          ),
                          title: Text(albumSongs[index].displayName),
                          onTap: () => playAlbumMusic(albumSongs[index]),
                        );
                      }),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children:<Widget>[
                Padding(
                    padding: const EdgeInsets.only(top:8.0),
                    child: Text(currAlbumSong.displayName,softWrap: false,),
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
              ]
            )
            )
        ],
      ),
    );
  }
}