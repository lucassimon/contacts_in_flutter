import 'dart:io';

import 'package:contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:contatos/helpers/contact_helper.dart';

enum OrderOptions {orderaz, orderza}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();
    // Contact c = Contact(name: 'Lucas', email: 'lucassrod@gmail.com', phone: '31991256055', img: 'teste');
    // helper.save(c);
    _getAllContacts();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de A a Z"),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z a A"),
                value: OrderOptions.orderza,
              )
            ],
            onSelected: _orderList,
          )
        ],

      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){ _showContactPage(); },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        },
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child:Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: contacts[index].img != null ? 
                    FileImage(
                      File(contacts[index].img)
                    ) :
                    AssetImage("images/0.jpeg"),
                    fit: BoxFit.cover
                  )
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(contacts[index].name ?? "", style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),),
                    Text(contacts[index].email ?? "", style: TextStyle(fontSize: 18.0),),
                    Text(contacts[index].phone ?? "", style: TextStyle(fontSize: 18.0),),
                  ],
                )
              )
            ]
          )
        ),
      ),
      onTap: () { _showOptions(context, index); },
    );
  }

  void _showOptions(BuildContext context, int index) {
    
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {

          },
          builder: (context) {
            return Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text("Ligar", style: TextStyle(color: Colors.red, fontSize: 20.0),),
                      onPressed: () {
                        launch("tel:${contacts[index].phone}");
                        Navigator.pop(context);
                      }
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text("Editar", style: TextStyle(color: Colors.red, fontSize: 20.0),),
                      onPressed: () {
                        Navigator.pop(context);
                        _showContactPage(contact: contacts[index]);
                      }
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text("Excluir", style: TextStyle(color: Colors.red, fontSize: 20.0),),
                      onPressed: () {
                        helper.deleteById(contacts[index].id);
                        setState(() {
                          contacts.removeAt(index);
                          Navigator.pop(context);
                        });
                      }
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    );
  }

  void _getAllContacts() {
    helper.fetchAll().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }

  void _showContactPage({Contact contact}) async {
    final reqContact = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContactPage(
        contact: contact,
      ))
    );
    if (reqContact != null) {
      if (contact != null) {
        await helper.update(reqContact);
      } else {
        await helper.save(reqContact);
      }
      _getAllContacts();
    }
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        contacts.sort(
          (a, b) {
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });
        break;
      case OrderOptions.orderza:
        contacts.sort(
          (a, b) {
            return b.name.toLowerCase().compareTo(a.name.toLowerCase());
          });
        break;

      default:
    }
    setState(() { });
  }
}