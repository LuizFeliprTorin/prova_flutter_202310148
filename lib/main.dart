import 'package:flutter/material.dart';
import 'database_helper.dart'; // Importa o arquivo do banco que criamos antes

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Prova Flutter - RA 202310148',
      theme: ThemeData(
        // TEMA VULCAN (Solicitado na prova)
        // Cor Primária: Red
        primaryColor: Colors.red,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          primary: Colors.red, 
          // Cor Secundária: Black54
          secondary: Colors.black54,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Lista para guardar as tarefas que vêm do banco
  List<Map<String, dynamic>> _tarefas = [];
  bool _isLoading = true;

  // Controladores dos campos de texto (Formulário)
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _prioridadeController = TextEditingController();
  final TextEditingController _ambienteController = TextEditingController(); // SEU CAMPO EXTRA

  // Função para carregar as tarefas do banco (READ)
  void _refreshTarefas() async {
    final data = await DatabaseHelper.instance.queryAllRows();
    setState(() {
      _tarefas = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshTarefas(); // Carrega a lista assim que o app abre
  }

  // Função para Adicionar nova tarefa (CREATE)
  Future<void> _addItem() async {
    await DatabaseHelper.instance.insert({
      DatabaseHelper.columnTitulo: _tituloController.text,
      DatabaseHelper.columnDescricao: _descricaoController.text,
      DatabaseHelper.columnPrioridade: _prioridadeController.text,
      DatabaseHelper.columnCriadoEm: DateTime.now().toString(), // Data automática
      DatabaseHelper.columnAmbienteExecucao: _ambienteController.text, // SEU CAMPO EXTRA
    });
    _refreshTarefas();
  }

  // Função para Atualizar tarefa existente (UPDATE)
  Future<void> _updateItem(int id) async {
    await DatabaseHelper.instance.update({
      DatabaseHelper.columnId: id,
      DatabaseHelper.columnTitulo: _tituloController.text,
      DatabaseHelper.columnDescricao: _descricaoController.text,
      DatabaseHelper.columnPrioridade: _prioridadeController.text,
      DatabaseHelper.columnCriadoEm: DateTime.now().toString(),
      DatabaseHelper.columnAmbienteExecucao: _ambienteController.text, // SEU CAMPO EXTRA
    });
    _refreshTarefas();
  }

  // Função para Deletar tarefa (DELETE)
  void _deleteItem(int id) async {
    await DatabaseHelper.instance.delete(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Tarefa deletada com sucesso!'),
      backgroundColor: Colors.red,
    ));
    _refreshTarefas();
  }

  // Mostra o formulário de cadastro/edição
  void _showForm(int? id) async {
    if (id != null) {
      // Se tiver ID, é edição: preenche os campos com os dados existentes
      final existingJournal =
          _tarefas.firstWhere((element) => element['id'] == id);
      _tituloController.text = existingJournal['titulo'];
      _descricaoController.text = existingJournal['descricao'];
      _prioridadeController.text = existingJournal['prioridade'];
      _ambienteController.text = existingJournal['ambienteExecucao']; // SEU CAMPO EXTRA
    } else {
      // Se não, limpa tudo para criar um novo
      _tituloController.clear();
      _descricaoController.clear();
      _prioridadeController.clear();
      _ambienteController.clear();
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          // Isso garante que o teclado não cubra o formulário
          bottom: MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(hintText: 'Título'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descricaoController,
              decoration: const InputDecoration(hintText: 'Descrição'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _prioridadeController,
              decoration: const InputDecoration(hintText: 'Prioridade (Alta/Média/Baixa)'),
            ),
            const SizedBox(height: 10),
            // --- SEU CAMPO PERSONALIZADO ---
            TextField(
              controller: _ambienteController,
              decoration: const InputDecoration(
                hintText: 'Ambiente de Execução',
                labelText: 'Ambiente (Dev/Prod)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (id == null) {
                  await _addItem();
                } else {
                  await _updateItem(id);
                }
                // Fecha o formulário e limpa os campos
                _tituloController.clear();
                _descricaoController.clear();
                _prioridadeController.clear();
                _ambienteController.clear();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Botão Vermelho (Sua cor primária)
                foregroundColor: Colors.white,
              ),
              child: Text(id == null ? 'Criar Novo' : 'Atualizar'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas Profissionais - RA 202310148', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red, // Sua cor primária
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _tarefas.length,
              itemBuilder: (context, index) => Card(
                color: Colors.white,
                margin: const EdgeInsets.all(15),
                elevation: 5, // Sombra
                child: ListTile(
                  // Ícone decorativo na cor secundária (Black54)
                  leading: const CircleAvatar(
                    backgroundColor: Colors.black54, 
                    child: Icon(Icons.work, color: Colors.white),
                  ),
                  title: Text(_tarefas[index]['titulo'], 
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Prioridade: ${_tarefas[index]['prioridade']}"),
                      // Mostrando seu campo extra na lista:
                      Text("Ambiente: ${_tarefas[index]['ambienteExecucao']}", 
                           style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        // Botão Editar
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showForm(_tarefas[index]['id']),
                        ),
                        // Botão Deletar
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteItem(_tarefas[index]['id']),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: Colors.red, // Sua cor primária
        onPressed: () => _showForm(null),
      ),
    );
  }
}