import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

var data = List<List<dynamic>>();
var items = List<List<dynamic>>();

class _HomePageState extends State<HomePage>{

  TextEditingController editingController = new TextEditingController();
  bool _decide = true;
  String extDir;

  Future _loadDbAsset() async {
    try{
      extDir = (await getExternalStorageDirectory()).path;
      debugPrint("Ext PATH: "+ extDir);
      await new Directory('$extDir/CSVfile').create(recursive: false);
      File filee = new File("$extDir/CSVfile/db.csv");
      String myData = await filee.readAsString();
//    final String myData = await rootBundle.loadString('assets/db.csv');
      debugPrint(myData);
      List<List<dynamic>> csvTable = CsvToListConverter().convert(myData);
      setState(() => data = csvTable);
    } on FileSystemException {
      debugPrint('hahaha');
      setState(() => _decide =false);
    }
    return data;
  }

  void filterSearchResults(String query) {
    List<List<dynamic>> dummySearchList = List<List<dynamic>>();
    dummySearchList.addAll(data);
    if(query.isNotEmpty) {
      debugPrint("isNotEmpty Items Length is : *******: ${items.length.toString()}");
      List<List<dynamic>> dummyListData = List<List<dynamic>>();
      for(int i = 0; i < dummySearchList.length; i++){
        var item = dummySearchList[i][2].toString().toLowerCase();
        if(item.contains(query.toLowerCase())){
          dummyListData.add(dummySearchList[i]);
          debugPrint('Query: $query  &  dummy: $item');
        }
      }
      /*
      dummySearchList.forEach((item) {
        if(item.contains(query)) {
          print('YES(*(*(*(*(*(*(**)*)*)*)*)*)');
          dummyListData.add(item);
        }
      });
      */

      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(data);
      });
    }

  }

  @override
  void initState() {
    _loadDbAsset().then((list){
      items.addAll(list);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Deny Market'),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  filterSearchResults(value);
                },
                controller: editingController,
                decoration: InputDecoration(
                    labelText: "Search",
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),
            _decide ? Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index){
                  return ListTile(
                    title: Text(items[index][2].toString()),
                    subtitle: Text(items[index][1].toString()),
                    trailing: Text(items[index][3].toString()),
                  );
                },
              ),
            ) : Padding(
              padding: EdgeInsets.all(12),
              child: Text('Please add csv file in [$extDir/CSVfile/db.csv]'),
            )
          ],
        ),
      ),
    );
  }
}