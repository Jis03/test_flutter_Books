import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllBooks extends StatefulWidget {
  const AllBooks({super.key});

  @override
  State<AllBooks> createState() => _AllBooksState();
}

class _AllBooksState extends State<AllBooks> {
  final CollectionReference books =
      FirebaseFirestore.instance.collection('Books');

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  Future<void> _addBook(BuildContext context) async {
    if (_nameController.text.trim().isEmpty ||
        _authorController.text.trim().isEmpty ||
        _typeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please fill in all fields before adding the book.')),
      );
      return;
    }

    try {
      await books.add({
        'book_name': _nameController.text.trim(),
        'author': _authorController.text.trim(),
        'type': _typeController.text.trim(),
      });
      print("Book added successfully!");
    } catch (e) {
      print("Error adding book: $e");
    }

    _nameController.clear();
    _authorController.clear();
    _typeController.clear();
  }

  Future<void> _deleteBook(String id) async {
    try {
      await books.doc(id).delete();
      print("Book deleted: $id");
    } catch (e) {
      print("Error deleting book: $e");
    }
  }

  Future<void> _editBook(
      String id, String name, String author, String type) async {
    TextEditingController nameController = TextEditingController(text: name);
    TextEditingController authorController =
        TextEditingController(text: author);
    TextEditingController typeController = TextEditingController(text: type);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Book'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Book Name')),
              TextField(
                  controller: authorController,
                  decoration: InputDecoration(labelText: 'Author')),
              TextField(
                  controller: typeController,
                  decoration: InputDecoration(labelText: 'Type')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await books.doc(id).update({
                    'book_name': nameController.text.trim(),
                    'author': authorController.text.trim(),
                    'type': typeController.text.trim(),
                  });
                  print("Book updated: $id");
                  Navigator.pop(context);
                } catch (e) {
                  print("Error updating book: $e");
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showAddBookForm(BuildContext context) {
    _nameController.clear();
    _authorController.clear();
    _typeController.clear();

showModalBottomSheet(
  backgroundColor: const Color.fromARGB(255, 239, 220, 207),
  context: context,
  isScrollControlled: true,
  builder: (BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Book Name',
              labelStyle: TextStyle(color: Color.fromARGB(255, 39, 26, 21)),
            ),
            style: TextStyle(color: Color.fromARGB(255, 39, 26, 21)),
          ),
          TextField(
            controller: _authorController,
            decoration: InputDecoration(
              labelText: 'Author',
              labelStyle: TextStyle(color: Color.fromARGB(255, 39, 26, 21)),
            ),
            style: TextStyle(color: Color.fromARGB(255, 39, 26, 21)),
          ),
          TextField(
            controller: _typeController,
            decoration: InputDecoration(
              labelText: 'Type',
              labelStyle: TextStyle(color: Color.fromARGB(255, 39, 26, 21)),
            ),
            style: TextStyle(color: Color.fromARGB(255, 39, 26, 21)),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 39, 26, 21), 
              foregroundColor: Colors.white, 
            ),
            onPressed: () {
              _addBook(context);
              Navigator.pop(context);
            },
            child: Text('Add Book'),
          ),
        ],
      ),
    );
  },
);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 226, 203, 187),
      appBar: AppBar(
      backgroundColor: Color.fromARGB(247, 75, 52, 26),
      title: Text('B O O K S' , style: TextStyle(color: const Color.fromARGB(255, 192, 158, 145)),)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Book collection',
              style: TextStyle(fontSize: 20, color: const Color.fromARGB(255, 39, 26, 21), fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: books.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No books found in Firestore'));
                }
return ListView(
  children: snapshot.data!.docs.map((book) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Color.fromARGB(255, 53, 37, 26),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(book['book_name'], 
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
        subtitle: Text(book['author'], 
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Color.fromARGB(255, 255, 255, 255)),
              onPressed: () => _editBook(
                  book.id, book['book_name'], book['author'], book['type']),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Color.fromARGB(255, 255, 255, 255)),
              onPressed: () => _deleteBook(book.id),
            ),
          ],
        ),
      ),
    );
  }).toList(),
);
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 239, 212, 172), 
        foregroundColor: const Color.fromARGB(255, 52, 37, 28), 
        shape: CircleBorder(),
        child: Icon(Icons.add),
        onPressed: () => _showAddBookForm(context),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 85, 56, 46),
        shape: CircularNotchedRectangle(),
        notchMargin: 10.0,
        child: SizedBox(height: 100),
      ),
      
    );
  }
}
