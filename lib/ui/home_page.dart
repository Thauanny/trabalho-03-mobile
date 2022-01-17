import 'dart:io';

import 'package:f_contact_ex/domain/contact.dart';
import 'package:f_contact_ex/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'contact_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();
  List<Contact> contatos = [];

  //carregando a lista de contatos do banco ao iniciar o app
  @override
  void initState() {
    super.initState();
    //then retorna um futuro e coloca em list
    updateList();
  }

  void updateList() {
    helper.getAllContact().then((list) {
      //atualizando a lista de contatos na tela
      setState(() {
        contatos = list.cast<Contact>();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "Contatos",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blueAccent[700],
              ),
              child: IconButton(
                  iconSize: 26,
                  color: Colors.white,
                  splashColor: Colors.blueGrey,
                  onPressed: () {
                    _showContactPage();
                  },
                  icon: Icon(Icons.mode_edit_rounded)),
            ),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _searchBar(),
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 250,
              child: ListView.builder(
                  padding: EdgeInsets.all(10.0),
                  itemCount: contatos.length,
                  itemBuilder: (context, index) {
                    return _contatoCard(context, index);
                  }),
            ),
          ),
        ],
      ),
    );
  }

  /// Função para criação de um card de contato para lista.
  Widget _contatoCard(BuildContext context, int index) {
    return GestureDetector(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                _contactImage(contact: contatos[index]),
                _contactInfo(contact: contatos[index]),
              ],
            ),
          ),
        ),
        onTap: () {
          _showContactPage(contact: contatos[index]);
        },
        onLongPress: () {
          _showOptions(context, index);
        });
  }

  //mostra as opções
  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            //onclose obrigatório. Não fará nada
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  //ocupa o mínimo de espaço.
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _optionItem(
                        text: 'Editar',
                        onPressed: () {
                          Navigator.pop(context);
                          _showContactPage(contact: contatos[index]);
                        }),
                    _optionItem(
                        text: 'Ligar',
                        onPressed: () {
                          launch("tel:${contatos[index].phone}");
                          Navigator.pop(context);
                        }),
                    _optionItem(
                        text: 'Excluir',
                        onPressed: () {
                          helper.deleteContact(contatos[index].id);
                          updateList();
                          Navigator.pop(context);
                        }),
                  ],
                ),
              );
            },
          );
        });
  }

  //mostra o contato. Parâmetro opcional
  void _showContactPage({Contact? contact}) async {
    Contact contatoRet = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact)));

    if (contatoRet.id == 0)
      await helper.saveContact(contatoRet);
    else
      await helper.updateContact(contatoRet);

    updateList();
  }

  Widget _optionItem({required String text, required Function? onPressed()}) =>
      Padding(
        padding: EdgeInsets.all(10.0),
        child: TextButton(
            child: Text(text,
                style: TextStyle(color: Colors.lightBlue, fontSize: 20.0)),
            onPressed: onPressed),
      );

  Widget _contactInfo({required Contact contact}) => Padding(
        padding: EdgeInsets.only(left: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //se não existe nome, joga vazio
            Text(
              contact.name,
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                contact.email,
                style: TextStyle(fontSize: 18.0, color: Colors.grey[800]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                contact.phone,
                style: TextStyle(fontSize: 18.0, color: Colors.grey[800]),
              ),
            ),
          ],
        ),
      );

  Widget _contactImage({required Contact contact}) => Container(
        width: 80.0,
        height: 80.0,
        decoration: BoxDecoration(
            color: Colors.grey[400],
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
                image: contact.img != ''
                    ? FileImage(File(contact.img))
                    : AssetImage("images/person.png") as ImageProvider)),
      );

  Widget _searchBar() => Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 50,
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search,
                color: Colors.black54,
                size: 25,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(50),
              ),
              fillColor: Colors.grey[200],
              filled: true,
              hintText: 'Procurar',
            ),
            onChanged: (value) async {
              var list = await helper.searchContacts(value);
              if (list.isEmpty) updateList();
              setState(() {
                contatos = list;
              });
            },
          ),
        ),
      );
}
