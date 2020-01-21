import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:lista_de_tarefas/models/Item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  var items = new List<Item>();

  HomePage() {
    items = [];
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void add(String nomeTarefa) {
    //if (nomeTarefa == "") return;

    setState(() {
      widget.items.add(
        Item(title: nomeTarefa, done: false),
      );
      save();
    });
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
      save();
    });
  }

  Future load() async {
    // await segura a execução do método até que ele receba o retorno
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');

    if (data != null) {
      //Iterable é uma coluna onde tem a iteração onde podemos percorrer ela pois é uma lista generica
      Iterable decoded = jsonDecode(data);

      //percorre o iterable e adiciona em nossa lista atraves do map string dynamic
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();

      setState(() {
        widget.items = result;
      });
    }
  }

  // Todo método que trabalha com SharedPreferences precisa ser async
  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  Widget FormUI() {
    return new Column(
      children: <Widget>[
        new TextFormField(
          decoration: new InputDecoration(hintText: 'Nome da Atividade'),
          maxLength: 25,
          validator: (String value) {
            if (value.length == 0) {
              return "Insira o nome da atividade";
            } else {
              return null;
            }
          },
        )
      ],
    );
  }

  showDialogAdd(BuildContext context) {
    var newTaskController = TextEditingController();
    final GlobalKey<FormState> _key = GlobalKey<FormState>();
    // configura o button
    Widget readyButton = FlatButton(
      child: Text("Pronto!"),
      onPressed: () {
        if (_key.currentState.validate()) {
          add(newTaskController.text);
          Navigator.pop(context);
        }
      },
    );

    Widget cancelButton = FlatButton(
      child: Text("Cancelar"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // final txtNewTask = TextFormField(
    //   controller: newTaskController,
    //   key: _key,
    //   decoration: new InputDecoration(hintText: 'Nome da atividade'),
    //   maxLength: 25,
    //   keyboardType: TextInputType.text,
    //   validator: (String value) {
    //     if (value.length == 0) {
    //       print("saddsadsadsadsadsadasds");
    //       return "Insira o nome da atividade";
    //     } else {
    //       print("eeeeeeeeeeeeeeeeeeeeeeeeeee");
    //       return null;
    //     }
    //   },
    // );

    // configura o  AlertDialog
    AlertDialog alerta = AlertDialog(
      title: Text("Criar nova tarefa"),
      // content: TextFormField(
      //   controller: newTaskCtrl,
      //   keyboardType: TextInputType.text,
      // ),
      content: new SingleChildScrollView(
        child: new Container(
          margin: new EdgeInsets.all(15.0),
          child: new Form(
            key: _key,
            child: FormUI(),
          ),
        ),
      ),
      actions: [
        cancelButton,
        readyButton,
      ],
    );
    // exibe o dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alerta;
      },
    );
  }

  //toda vez a aplicação iniciar irá chamar apenas uma vez o load
  _HomePageState() {
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = widget.items[index];

          return Dismissible(
            child: CheckboxListTile(
              title: Text(item.title),
              value: item.done,
              onChanged: (value) {
                setState(() {
                  item.done = value;
                  save();
                });
              },
            ),
            key: Key(item.title),
            background: Container(
              color: Colors.red,
            ),
            onDismissed: (direction) {
              if (direction == DismissDirection.endToStart) {
                remove(index);
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialogAdd(context);
        }, //add,
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
    );
  }
}
