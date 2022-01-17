import 'dart:io';

import 'package:f_contact_ex/domain/contact.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatefulWidget {
  Contact? contact;

  //construtor que inicia o contato.
  //Entre chaves porque é opcional.
  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Contact? _editedContact;
  bool _userEdited = false;

  //para garantir o foco no nome
  final _nomeFocus = FocusNode();

  //controladores
  TextEditingController nomeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();

    //acessando o contato definido no widget(ContactPage)
    //mostrar se ela for privada
    if (widget.contact == null)
      _editedContact = Contact();
    else {
      _editedContact = widget.contact;

      nomeController.text = _editedContact!.name;
      emailController.text = _editedContact!.email;
      phoneController.text = _editedContact!.phone;
    }
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Abandonar alteração?"),
              content: Text("Os dados serão perdidos."),
              actions: <Widget>[
                TextButton(
                    child: Text("cancelar"),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                TextButton(
                  child: Text("sim"),
                  onPressed: () {
                    //desempilha 2x
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
    } else {
      return Future.value(true);
    }
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    //com popup de confirmação
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.lightBlue,
            title: Text(_editedContact!.name),
            centerTitle: true),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editedContact!.name.isNotEmpty)
              Navigator.pop(context, _editedContact);
            else
              FocusScope.of(context).requestFocus(_nomeFocus);
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.lightBlue,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                    width: 140.0,
                    height: 140.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: _editedContact!.img != ''
                                ? FileImage(File(_editedContact!.img))
                                : AssetImage('images/person.png')
                                    as ImageProvider))),
                onTap: () {
                  ImagePicker()
                      .getImage(source: ImageSource.camera, imageQuality: 50)
                      .then((file) {
                    if (file == null)
                      return;
                    else {
                      setState(() {
                        _editedContact!.img = file.path;
                      });
                    }
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SizedBox(
                    height: 80,
                    width: MediaQuery.of(context).size.width - 90,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            child: Container(
                              width: 60.0,
                              height: 60.0,
                              decoration: BoxDecoration(
                                color: Colors.green[900],
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                Icons.message,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {
                              launch("sms:${widget.contact!.phone}");
                            },
                          ),
                          GestureDetector(
                            child: Container(
                              width: 60.0,
                              height: 60.0,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent[400],
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                Icons.phone,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () => launch("tel:${widget.contact!.phone}"),
                          ),
                          GestureDetector(
                            child: Container(
                              width: 60.0,
                              height: 60.0,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                Icons.mail,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {
                              String? encodeQueryParameters(
                                  Map<String, String> params) {
                                return params.entries
                                    .map((e) =>
                                        '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                                    .join('&');
                              }

                              final Uri emailLaunchUri = Uri(
                                scheme: 'mailto',
                                path: widget.contact!.email,
                                query: encodeQueryParameters(<String, String>{
                                  'subject':
                                      'Example Subject & Symbols are allowed!'
                                }),
                              );

                              launch(emailLaunchUri.toString());
                            },
                          ),
                        ])),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: nomeController,
                  focusNode: _nomeFocus,
                  decoration: InputDecoration(labelText: "Nome"),
                  onChanged: (text) {
                    _userEdited = true;
                    setState(() {
                      _editedContact!.name = text;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: "E-mail"),
                  onChanged: (text) {
                    _userEdited = true;
                    _editedContact!.email = text;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: "Telefone"),
                  onChanged: (text) {
                    _userEdited = true;
                    _editedContact!.phone = text;
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
