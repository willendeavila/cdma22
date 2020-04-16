import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'client_model.dart';
import 'database.dart';

void main() => runApp(MaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // data for testing
  List<Cliente> testClients = [
    Cliente(nome: "Dick", sobrenome: "Vigarista", marcado: false),
    Cliente(nome: "Penélope", sobrenome: "Charmosa", marcado: true),
    Cliente(nome: "Medinho", sobrenome: "Beltrano", marcado: false),
    Cliente(nome: "Muttley", sobrenome: "Siclano", marcado: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CDMA22 - Clientes"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.create),
            onPressed: () {
              _addCliente(context);
              //DBProvider.db.deleteAll();
              //setState(() {});
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              DBProvider.db.deleteAll();
              setState(() {});
            },
          )
        ],
      ),
      body: FutureBuilder<List<Cliente>>(
        future: DBProvider.db.getAllClientes(),
        builder: (BuildContext context, AsyncSnapshot<List<Cliente>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                Cliente item = snapshot.data[index];
                return Dismissible(
                  key: UniqueKey(),
                  background: Container(color: Colors.red),
                  onDismissed: (direction) {
                    DBProvider.db.deleteCliente(item.id);
                  },
                  child: ListTile(
                    title: Text(item.nome + " " + item.sobrenome),
                    leading: Text(item.id.toString()),
                    trailing: Checkbox(
                      onChanged: (bool value) {
                        DBProvider.db.blockOrUnblock(item);
                        setState(() {});
                      },
                      value: item.marcado,
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          Cliente rnd = testClients[math.Random().nextInt(testClients.length)];
          await DBProvider.db.newCliente(rnd);
          setState(() {});
        },
      ),

    );
  }

  Cliente novoCliente = new Cliente();
  List str;

  void _addCliente(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Dados Cliente"),
          actions: <Widget>[
            FlatButton(
              //onPressed: () => null,
              onPressed: () => _salvarCliente(),
              child: Text("Incluir"),
            ),
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancelar"),
            ),
          ],
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(
              labelText: "Nome + Sobrenome",
              hintText: "Digite aqui ...",
            ),
            onChanged: (valor) async {
              
              str = valor.split(" ");
              novoCliente.nome = str[0];
              novoCliente.sobrenome = str[1];
              novoCliente.marcado = false;
              //await DBProvider.db.newCliente(novoCliente);
              //setState(() {});
            },
          ),
        );
      },
    );
  } // fim void addCliiente

  _salvarCliente() async {
    await DBProvider.db.newCliente(novoCliente);
    setState(() {});
    Navigator.of(context).pop();
  }
}
