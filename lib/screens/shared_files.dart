// import 'dart:html';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:path_provider_ex/path_provider_ex.dart';

class SharedFiles extends StatefulWidget {
  const SharedFiles({Key? key}) : super(key: key);

  @override
  _SharedFilesState createState() => _SharedFilesState();
}

class _SharedFilesState extends State<SharedFiles> {
  var files;
  bool pressed = false;
  var itemPressed = [];

  void getFiles() async{
    List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
    var root = storageInfo[0].rootDir; //storageInfo[1] for SD card, geting the root directory
    var fm = FileManager(root: Directory(root)); //
    files = await fm.filesTree(
      //set fm.dirsTree() for directory/folder tree list
        excludedPaths: ["/storage/emulated/0/Bluetooth"],
        extensions: ["txt"] //optional, to filter files, remove to list all,
      //remove this if your are grabbing folder list
    );
    setState(() {}); //update the UI
  }


  @override
  void initState() {
    getFiles(); //call getFiles() function on initial state.
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFffffff),
        iconTheme: IconThemeData(color: Color(0xFF005f81)),
        elevation: 2.0,
        toolbarHeight: 68.0,
        titleSpacing: 0,

        automaticallyImplyLeading: pressed ? false : true,
        title: pressed ?
              Row(children: [
                IconButton(onPressed: (){
                  setState(() {
                    pressed = !pressed;
                  });
                }, icon: Icon(Icons.arrow_back, size: 28)),
                Text("${itemPressed.where((element) => element == true).length} selected item(s)", style: TextStyle(color: Color(0xFFe0115f), fontSize: 14.0, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ],)
            :
              Text('RECEIVED FILES',
                  style: TextStyle(color: Color(0xFFe0115f), fontSize: 14.0, fontWeight: FontWeight.bold, letterSpacing: 2)),
        actions: pressed ?
          [Icon(Icons.delete, size: 24), SizedBox(width: 20,), Icon(Icons.send, size: 24),SizedBox(width: 20,)] :
          [Icon(Icons.search_rounded, size: 28), SizedBox(width: 10,), Icon(Icons.more_vert, size: 28), SizedBox(width: 16,)],
      ),

        body:files == null? Text("Searching Files"):
        Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),

          child: ListView.builder(  //if file/folder list is grabbed, then show here
            itemCount: files?.length ?? 0,
            itemBuilder: (context, index) {
              itemPressed.add(false);
              return GestureDetector(
                child: ListTile(
                  title: Text(files[index].path.split('/').last),
                  leading: Icon(Icons.insert_drive_file, size: 20, color: Color(0xFFc0c0c0)),
                  trailing: pressed ? Icon(Icons.check_circle, color: itemPressed[index] ? Color(0xFF005f81) : Color(0xFFc0c0c0),) : null,
                ),
                onLongPress: (){
                  setState(() {
                    pressed = true;
                    itemPressed[index] = !itemPressed[index];
                  });
                },
                onTap: (){
                   if(pressed){
                      setState(() {
                        itemPressed[index] = !itemPressed[index];
                      });
                   }
                },
              );
            },
          ),
        )
    );
  }
}
