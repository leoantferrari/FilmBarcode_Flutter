
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:http/http.dart' as http;
import 'package:vibration/vibration.dart';

void main() {
  runApp(FilmApp());
}

class FilmApp extends StatefulWidget{


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _FilmState();
  }

}


class _FilmState extends State<FilmApp>{
  String barcode = "";
  String movieTitle = "";
  String movieURL = "";
  List<Film> films =[Film("h345alah", "325324994", "not found"), Film("halah", "32994", "not found")
  ];


  void initState(){

  }

  Widget filmTemplate(film){
  return Card(
      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),

      child: Padding(

        padding: const EdgeInsets.all(12.0),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: <Widget>[

            Text(

              film.name,

              style: TextStyle(

                fontSize: 18.0,

                color: Colors.grey[600],

              ),

            ),

            SizedBox(height: 6.0),

            Text(

              film.upc,

              style: TextStyle(

                fontSize: 14.0,

                color: Colors.grey[800],

              ),

            ),

          ],

        ),

      ),
  );

  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(

        home: Scaffold(

          appBar: AppBar(
            backgroundColor: Colors.lightBlue,

              title: const Text('Film Scanner'),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: 'share',
                  onPressed: (){
                    Share.share('Omg look at this barcode I just scanned... :  ${movieTitle}, ${movieURL} ,${barcode}', subject: 'omg look at that guys hood');
                  },
                ),
              ]
          ),

          body:new Center(
            child: new Column(
              children: <Widget>[
                new Container(
                  child: new RaisedButton(
                      onPressed: barcodeScanning, child: new Text("Capture image")),
                  padding: const EdgeInsets.all(8.0),
                ),
                new Padding(
                  padding: const EdgeInsets.all(8.0),
                ),
                new Image.network(movieURL),
                new Text("UPC : " + barcode, style: TextStyle(color: Colors.black, fontSize: 20.0), textAlign: TextAlign.center),
                // displayImage(),
                new Center(
                  child: new Text("Name: "+ movieTitle, style: TextStyle(color: Colors.black, fontSize: 20.0), textAlign: TextAlign.center)

                  ),

              ],
            ),
          ),
        )


    );
  }
  Future<http.Response> amazonCall(String upc) {
    return http.get("https://www.amazon.com/s?k="+upc);
  }
  String getPicUrl(String htmlString){

    int index =htmlString.indexOf("<span data-component-type=\"s-product-image\" class=\"rush-component\">");
    if (index > 0)
    {

      String subsource = htmlString.substring(index);

      var start1 = subsource.indexOf("<img");

      var startOfProductNameIndex = subsource.indexOf("alt=\"", start1) + 5;

      var endOfProductNameIndex = subsource.indexOf("\"", startOfProductNameIndex);

      var startOfProductNameImg = subsource.indexOf("src=\"", start1) + 5;

      var endOfProductNameImg = subsource.indexOf("\"", startOfProductNameImg);



      var subsource2 = subsource.substring(startOfProductNameIndex, endOfProductNameIndex );

      var imgLink = subsource.substring(startOfProductNameImg, endOfProductNameImg);
      movieTitle = subsource2;
      movieURL = imgLink;

    }
    else
    {
      movieTitle = "${barcode} Not found";
      movieURL = "Not Found";

    }


  }
  Future barcodeScanning() async {
//imageSelectorGallery();


    try {
      ScanResult result = await BarcodeScanner.scan();
      String barcode = result.rawContent;
      Vibration.vibrate(duration: 500);
      http.Response html= await amazonCall(barcode);
      getPicUrl(html.body);
      setState(() => this.barcode = barcode);



    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          this.barcode = 'No camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.barcode =
      'Nothing captured.');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }

}
class Film {
  final String name;
  final String upc;
  final String url;

  Film(this.name, this.upc, this.url);

  Film .fromJson(Map<String, dynamic> json)
      : name=json['name'],
        upc=json['upc'],
        url=json['url'];

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'ups': upc,
        'url': url,
      };

}

