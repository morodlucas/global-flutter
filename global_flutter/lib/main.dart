import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(EcoWiseApp());
}

class EcoWiseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoWise',
      theme: ThemeData(primarySwatch: Colors.green),
      home: TipsListScreen(),
    );
  }
}

// listagem de dica
class TipsListScreen extends StatefulWidget {
  @override
  _TipsListScreenState createState() => _TipsListScreenState();
}

class _TipsListScreenState extends State<TipsListScreen> {
  List<dynamic> tips = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTips();
  }

  Future<void> fetchTips() async {
    try {
      final response =
      await Dio().get('https://gdapp.com.br/api/sustainable-tips');
      setState(() {
        tips = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Erro ao buscar dicas: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dicas Sustentáveis'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddTipScreen()),
              ).then((_) => fetchTips());
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : tips.isEmpty
          ? Center(child: Text('Nenhuma dica cadastrada ainda.'))
          : ListView.builder(
        itemCount: tips.length,
        itemBuilder: (context, index) {
          final tip = tips[index];
          return Card(
            child: ListTile(
              title: Text(tip['title']),
              subtitle: Text(
                  '${tip['category']} - Sugestão de ${tip['student']}'),
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(tip['title']),
                  content: Text(tip['description']),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Fechar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// cadastro de nova dica
class AddTipScreen extends StatefulWidget {
  @override
  _AddTipScreenState createState() => _AddTipScreenState();
}

class _AddTipScreenState extends State<AddTipScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController studentController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool isSubmitting = false;

  Future<void> submitTip() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'category': categoryController.text,
      'title': titleController.text,
      'student': studentController.text,
      'description': descriptionController.text,
    };

    setState(() {
      isSubmitting = true;
    });

    try {
      await Dio().post(
        'https://gdapp.com.br/api/sustainable-tips',
        data: data,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dica cadastrada com sucesso!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar a dica.')),
      );
      print("Erro ao enviar dica: $e");
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastrar Nova Dica')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: categoryController,
                decoration: InputDecoration(labelText: 'Categoria'),
                validator: (value) =>
                value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Título'),
                validator: (value) =>
                value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: studentController,
                decoration: InputDecoration(labelText: 'Estudante (Nome ou RM)'),
                validator: (value) =>
                value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Descrição'),
                maxLines: 3,
                validator: (value) =>
                value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              SizedBox(height: 20),
              isSubmitting
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: submitTip,
                child: Text('Cadastrar Dica'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
