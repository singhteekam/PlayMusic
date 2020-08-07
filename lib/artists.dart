import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:PlayMusic/allSongs.dart';

class Artists extends StatefulWidget {
  @override
  _ArtistsState createState() => _ArtistsState();
}

class _ArtistsState extends State<Artists> {
  List<ArtistInfo> artists;

  @override
  void initState() {
    super.initState();
    getAllArtist();
  }

  getAllArtist() async {
    final FlutterAudioQuery audioQuery = FlutterAudioQuery();
    artists = await audioQuery.getArtists(); // returns all artists available
    setState(() {});
    artists.forEach((artist) {
      // print(artist); /// prints all artist property values
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: artists==null?Center(child:CircularProgressIndicator()):ListView.builder(
          itemCount: artists.length,
          itemBuilder: (context, int index) {
            return Container(
              child: ListTile(
                leading: Icon(
                  Icons.music_note,
                  color: Colors.green,
                ),
                title: Text(artists[index].name),
                onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (context) => ArtistSongs(
                    totalSongs: artists[index].numberOfTracks,
                    currArtist: artists[index].name,
                  ),
                )),
              ),
            );
          }),
    );
  }
}

class ArtistSongs extends StatefulWidget {
  final totalSongs;
  final currArtist;
  ArtistSongs({this.totalSongs, this.currArtist});
  @override
  _ArtistSongsState createState() =>
      _ArtistSongsState(totalSongs: totalSongs, currArtist: currArtist);
}

class _ArtistSongsState extends State<ArtistSongs> {
  final totalSongs;
  final currArtist;
  _ArtistSongsState({this.totalSongs, this.currArtist});

  List<SongInfo> songs;
  SongInfo currArtistSong;
  Duration _duration = new Duration();
  Duration _position = new Duration();
  Icon icon=Icon(Icons.play_arrow,);
  bool isPlaying=false;

  @override
  void initState() {
    super.initState();
    getAllArtistSongs();
    initArtistPlay();
  }

  getAllArtistSongs() async {
    songs = await audioQuery.getSongsFromArtist(artist: currArtist);
    currArtistSong=songs[0];
    setState(() {});
    // songs.forEach((element) {print(element);});
  }


  initArtistPlay() async {
    audioPlayer.durationHandler = (d) => setState(() {
          _duration = d;
        });
    audioPlayer.positionHandler = (p) => setState(() {
          _position = p;
        });
  }

  playArtistMusic(SongInfo url) {
    setState(() {
      audioPlayer.stop();
      audioPlayer.play(url.filePath, isLocal: true);
      isPlaying=true;
      icon=Icon(Icons.pause,);
      currArtistSong=url;
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
      int x=songs.indexOf(currArtistSong);
      if(x==0)
      x=songs.length;
      SongInfo url=songs[x-1];
      audioPlayer.play(url.filePath, isLocal: true);
      isPlaying=true;
      icon=Icon(Icons.pause);
      currArtistSong=songs[x-1];
    });
  }
  playNext() {
    setState(() {
      int x=songs.indexOf(currArtistSong);
      if(x==songs.length-1)
      x=-1;
      SongInfo url=songs[x+1];
      audioPlayer.play(url.filePath, isLocal: true);
      isPlaying=true;
      icon=Icon(Icons.pause);
      currArtistSong=songs[x+1];
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
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: ListView.builder(
                itemCount: int.parse(totalSongs),
                itemBuilder: (context, int index) {
                  return ListTile(
                    leading: Icon(
                      Icons.music_note,
                      color: Colors.green,
                    ),
                    title: Text(songs[index].displayName),
                    onTap: () => playArtistMusic(songs[index]),
                  );
                }),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children:<Widget>[
                Padding(
                    padding: const EdgeInsets.only(top:8.0),
                    child: Text(currArtistSong.filePath.split("/").last,softWrap: false,),
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
