import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';

const String request = "https://api.hgbrasil.com/finance?format=json&key=c57247b0";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder:
        OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        focusedBorder:
        OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        hintStyle: TextStyle(color: Colors.amber),
      )
    )
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return (jsonDecode(response.body));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dollar = 0;
  double euro = 0;

  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();

  void _realChanged (String text) {
    double real = double.parse(text);

    dollarController.text = (real / dollar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }
  void _dollarChanged (String text) {
    double dollar = double.parse(text);
    realController.text = (dollar * this.dollar).toStringAsFixed(2);
    euroController.text = (dollar * this.dollar / euro).toStringAsFixed(2);
  }
  void _euroChanged (String text) {
    double euro = double.parse(text);
    realController.text = (this.euro).toStringAsFixed(2);
    dollarController.text = (euro * this.euro / dollar).toStringAsFixed(2);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(
          'Conversor de Moeda'
        ),
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch(snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                  child: Text(
                      'Carregando dados',
                       style: TextStyle(
                         color: Colors.amber,
                         fontSize: 25
                       ),
                  )
              );
            default:
              if(snapshot.hasError) {
                return Center(
                    child: Text(
                      'Erro ao carregar dados',
                      style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25
                    ),
                  )
                );
              } else {
                dollar = snapshot.data!['results']['currencies']['USD']['buy'];
                euro = snapshot.data!['results']['currencies']['EUR']['buy'];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.monetization_on, size: 150, color: Colors.amber),
                      Divider(),
                      buildTextField("Reais", "R\$", realController, _realChanged),
                      Divider(),
                      buildTextField("Dollar", "\$", dollarController, _dollarChanged),
                      Divider(),
                      buildTextField("Euro", "€", euroController, _euroChanged)
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix, TextEditingController c, Function f) {
  return TextField(
    controller: c,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            color: Colors.amber
        ),
        border: OutlineInputBorder(),
        prefixText: prefix
    ),
    style: TextStyle(
        color: Colors.amber,
        fontSize: 25
    ),
    onChanged: (text) => f(text),
    keyboardType: TextInputType.number,
  );
}