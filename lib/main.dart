import 'package:flutter/material.dart';
import 'db_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestor de tareas',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto', // Usa fuentes nativas limpias
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff6366f1), // Color índigo moderno e institucional
          brightness: Brightness.light,
          surface: Colors.white,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _journals = [];
  bool _isLoading = true;

  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
    } else {
      _titleController.text = '';
      _descriptionController.text = '';
    }

    showModalBottomSheet(
        context: context,
        elevation: 10,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        barrierColor: Colors.black54, // Fondo oscuro sutil al abrirse
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        builder: (_) => Padding(
              padding: EdgeInsets.only(
                top: 15,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    id == null ? 'Nueva Tarea' : 'Editar Tarea',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1e1b4b),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    controller: _titleController,
                    autofocus: true,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[50],
                      labelText: 'Título de la actividad',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      floatingLabelStyle: const TextStyle(color: Color(0xff6366f1)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xff6366f1), width: 2),
                      ),
                      prefixIcon: const Icon(Icons.assignment_rounded, color: Color(0xff6366f1)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[50],
                      labelText: 'Descripción o notas adicionales',
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      floatingLabelStyle: const TextStyle(color: Color(0xff6366f1)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xff6366f1), width: 2),
                      ),
                      prefixIcon: const Icon(Icons.notes_rounded, color: Color(0xff6366f1)),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      backgroundColor: const Color(0xff6366f1),
                      foregroundColor: Colors.white,
                      elevation: 2,
                    ),
                    onPressed: () async {
                      if (_titleController.text.trim().isEmpty) return;
                      if (id == null) {
                        await _addItem();
                      } else {
                        await _updateItem(id);
                      }
                      _titleController.text = '';
                      _descriptionController.text = '';
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      id == null ? 'Guardar Tarea' : 'Actualizar Cambios',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  )
                ],
              ),
            ));
  }

  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _titleController.text, _descriptionController.text);
    _refreshJournals();
    _showSnackBar('Tarea añadida con éxito', Colors.green);
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
    _refreshJournals();
    _showSnackBar('Tarea actualizada correctamente', Colors.indigo);
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    _refreshJournals();
    _showSnackBar('Tarea eliminada del flujo', Colors.redAccent);
  }

  void _showSnackBar(String text, Color background) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      backgroundColor: background,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8fafc), // Color gris pizarra muy claro de fondo
      appBar: AppBar(
        title: const Text(
          'Gestor de tareas',
          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xff4f46e5), Color(0xff818cf8)], // Degradado corporativo premium
            ),
          ),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xff4f46e5)))
          : _journals.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xffe0e7ff),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.task_alt_rounded, size: 70, color: Color(0xff4f46e5)),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Tu espacio está despejado',
                          style: TextStyle(color: Color(0xff1e1b4b), fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Organiza tu día agregando tu primera tarea con el botón de abajo.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _journals.length,
                  itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        // Línea lateral izquierda decorativa de estatus
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Color(0xff4f46e5), width: 6),
                          ),
                        ),
                        child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            title: Text(
                              _journals[index]['title'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xff1e1b4b)),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                _journals[index]['description'] ?? '',
                                style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.3),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => _showForm(_journals[index]['id']),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      child: const Icon(Icons.edit_outlined, color: Color(0xff4f46e5), size: 22),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => _deleteItem(_journals[index]['id']),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(null),
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text('Nueva Tarea', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5)),
        backgroundColor: const Color(0xff4f46e5),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}