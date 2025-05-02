import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagePeopleScreen extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage People'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddPersonScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('people').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final people = snapshot.data!.docs;

          return ListView.builder(
            itemCount: people.length,
            itemBuilder: (context, index) {
              var person = people[index];
              return ListTile(
                title: Text(person['name'] ?? ''),
                subtitle: Text(
                  '${person['email'] ?? ''}\nPhone: ${person['phone'] ?? ''}\nDOB: ${person['dob'] ?? ''}',
                ),
                isThreeLine: true,
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditPersonScreen(personId: person.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------------- ADD PERSON SCREEN ----------------------

class AddPersonScreen extends StatefulWidget {
  @override
  _AddPersonScreenState createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends State<AddPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  void addPerson() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('people').add({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'dob': dobController.text.trim(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Person added successfully')));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Person')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Enter name' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Enter email' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter phone number'
                            : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: dobController,
                decoration: InputDecoration(labelText: 'Date of Birth'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Enter DOB' : null,
              ),
              SizedBox(height: 30),
              ElevatedButton(onPressed: addPerson, child: Text('Add Person')),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------- EDIT PERSON SCREEN ----------------------

class EditPersonScreen extends StatefulWidget {
  final String personId;

  EditPersonScreen({required this.personId});

  @override
  _EditPersonScreenState createState() => _EditPersonScreenState();
}

class _EditPersonScreenState extends State<EditPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPersonData();
  }

  void loadPersonData() async {
    var doc =
        await FirebaseFirestore.instance
            .collection('people')
            .doc(widget.personId)
            .get();
    final data = doc.data();
    if (data != null) {
      nameController.text = data['name'] ?? '';
      emailController.text = data['email'] ?? '';
      phoneController.text = data['phone'] ?? '';
      dobController.text = data['dob'] ?? '';
      setState(() {});
    }
  }

  void saveChanges() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('people')
          .doc(widget.personId)
          .update({
            'name': nameController.text.trim(),
            'email': emailController.text.trim(),
            'phone': phoneController.text.trim(),
            'dob': dobController.text.trim(),
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Changes saved')));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Person')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Enter name' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Enter email' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter phone number'
                            : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: dobController,
                decoration: InputDecoration(labelText: 'Date of Birth'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Enter DOB' : null,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: saveChanges,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
