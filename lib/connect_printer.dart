import 'package:Restaurant/add_printer.dart';
import 'package:Restaurant/printer_helper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:line_icons/line_icons.dart';

class ConnectPrinterPage extends StatefulWidget {
ConnectPrinterState createState() => ConnectPrinterState();
}

class ConnectPrinterState extends State<ConnectPrinterPage> {

  List<Printer> printers = [];
  int id;
  @override 
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => getPrinters());
  }

  void getPrinters() async  {
    var g = await PrinterProvider.shared.getDefaultPrinter();
    var f = await PrinterProvider.shared.getAllPrinters();
    setState(() {
      printers = f;
      if (g != null) {
         id = g.id;
         
      }
      print('found $g');
    });
  }

  final UniqueKey uniqueKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    
    return FocusDetector(
      key: uniqueKey,
      onFocusGained: () {
        getPrinters();
      },
      child: Scaffold(

      appBar: AppBar(
        title: Text('Connect Printers', style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.white,
        centerTitle: true,
        shadowColor: Colors.transparent,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => AddPrinterPage()
              ));
            },
            child: Container(
            height: 50,
            width: 50,
            child: Center(
              child: Text('Add', style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),),
            ),
          ),
          )
        ],
      ),
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: printers.isEmpty ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Text('No Printers added', style: TextStyle(fontSize: 12),),
                 SizedBox(height: 40,),
                 GestureDetector(
                   onTap: () {
                     Navigator.push(context, MaterialPageRoute(
                       builder: (context) => AddPrinterPage()
                     ));
                   },
                   child: Container(
                   height: 40,
                   width: 200,
                   
                   child: Center(
                     child: Text('Add Printer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                   ),
                   decoration: BoxDecoration(
                     color: Colors.orange,
                     borderRadius: BorderRadius.circular(30)
                   ),
                 )
                 )
              ],
            ) : ListView.separated(
              separatorBuilder: (context, index) {
                return Divider(height: 20);
              },
              itemCount: printers.length,
              itemBuilder: (context, index) {
                final printer = printers[index];
                return Dismissible(
                  background: stackBehindDismiss(),
                  key: ObjectKey(printers[index]),
                  child: RadioListTile(
                    title: Text('${printer.name}'),
                    subtitle: Text('${printer.ip}'),
                    groupValue: id,
                    value: printer.id,
                    onChanged: (value ) async {
                      setState(() {
                        id = value;
                      });            
                      await PrinterProvider.shared.setAsDefaultPrinter(printer);
                      Fluttertoast.showToast(msg: '${printer.name} is now your default printer');
                    },
                    
                  ),
                   onDismissed: (direction) {
                        var item = printers.elementAt(index);
                        //To delete
                        deleteItem(item, index);
      
                   }
                        );
                
              }
            )
           
        ),
      ),
    )
    );
  }

void deleteItem(Printer printer, index) async {
    /*
    By implementing this method, it ensures that upon being dismissed from our widget tree, 
    the item is removed from our list of items and our list is updated, hence
    preventing the "Dismissed widget still in widget tree error" when we reload.
    */
    setState(() {
      printers.removeAt(index);
    });
      await PrinterProvider.shared.deletePrinter(printer.id);
      Fluttertoast.showToast(msg: '${printer.name} was removed');
      getPrinters();
      
    
  }
  
  void undoDeletion(index, printer) {
    /*
    This method accepts the parameters index and item and re-inserts the {item} at
    index {index}
    */
    setState(() {
      printers.insert(index, printer);
    });
  }

  Widget stackBehindDismiss() {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20.0),
      color: Colors.red,
      child: Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }
}