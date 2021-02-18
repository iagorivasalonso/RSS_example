import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RSSDemo extends StatefulWidget{
   RSSDemo() : super();

   final String title="RSS";

   @override
   RSSDemoState createState() =>RSSDemoState();
}
class RSSDemoState extends State<RSSDemo>{

  //aqui vamos a poner la direccion para el RSS
  static const String URL_RSS = 'https://www.farodevigo.es/rss/section/7619';

  //creamos una variable para el titulo y string y otra para el contenido RSS
  RssFeed _feed;
  String _title;
  //definimos constantes para los mensajes
  static const String loadingFeedMsg='Loading....';
  static const String loadingFeedErrorMsg='Error Loading...';
  static const String loadingOpenFeedErrorMsg='Error Open...';
  static const String placeholderImg='No image';

  updateTitle(title){
    setState(() {             //aqui le ponemos el titulo
      _title = title;
    });
  }
//aqui  actualiza
  updateFeed(feed){
    setState(() {
      _feed = feed;
    });
  }
  load() async{                           //Si hay datos los carga
    updateTitle(loadingFeedMsg);
    loadfeed().then((result){
      if(result == null || result.toString().isEmpty){
        updateTitle(loadingFeedMsg);
        return;
      }
      updateFeed(result);
      updateTitle(_feed.title);
    });
  }
  Future<RssFeed> loadfeed() async{
    try{                                        //aqui es donde se hace la conexion
         final client=http.Client();
         final response =await client.get(URL_RSS);
         return RssFeed.parse(response.body);
    }catch(e) {
      //
    }
    return null;
  }

  //Este metodo sera para obtener en contenido de la noticia
  Future<void> openFeed (String url) async{
    if(await canLaunch(url)){
      await launch(
          url,
          forceSafariVC: true,
          forceWebView: false
      );
      return;
    }
    updateTitle(loadingOpenFeedErrorMsg);
  }
  void initState(){
    super.initState();
    updateTitle(widget.title);
    load();
  }
//aqui se definen las partes de cada elemento para crear el ListWiev
  title(title){
    return Text(title, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w300),
               maxLines: 2, overflow: TextOverflow.ellipsis,);
  }

  subtitle(title){
    return Text(title, style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w100),
      maxLines: 1, overflow: TextOverflow.ellipsis,);
  }

 thubnail(imageUrl){
    return Padding(
      padding: EdgeInsets.only(left: 15),
      child: CachedNetworkImage(
         placeholder: (context,url) => Image.asset(placeholderImg),
         imageUrl: imageUrl,
         height: 40,
         width: 60,
        alignment: Alignment.center,
      ),
     );
 }
 righIcon(){
    return Icon(
        Icons.keyboard_arrow_down,
        color: Colors.amberAccent,
        size: 30,
    );
 }
 list(){
    return ListView.builder(
        itemCount: _feed.items.length,
        itemBuilder: (BuildContext context, int index){
           final item=_feed.items[index];
           return ListTile(
              title: title(item.title),
              subtitle: subtitle(item.pubDate),
              leading: thubnail(item.enclosure.url),
              trailing: righIcon(),
              contentPadding: EdgeInsets.all(5.0),
              onTap: (){
                openFeed(item.link);
              },
           );
        },
    );
 }
 isEmpty(){
    return _feed == null || _feed.items==null;
 }
 body(){
    return isEmpty()
        ?Center(
           child: CircularProgressIndicator(),
         ):list();
 }
  @override
  Widget build(BuildContext context){

     return Scaffold(
       appBar: AppBar(
         title: Text(_title),
       ),
       body:  body(),
     );

  }
}




