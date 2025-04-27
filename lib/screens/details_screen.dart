import 'package:assessment/models/document.dart';
import 'package:assessment/services/api_service.dart';
import 'package:flutter/material.dart';

class DetailsScreen extends StatefulWidget {
  final Document? document;
  final Function(String firstName, String lastName, String? notes) onCreate;
  final Function(Document updatedDocument)? onUpdate;
  final Function(String documentId)? onDelete;

  const DetailsScreen({
    super.key,
    this.document,
    required this.onCreate,
    this.onUpdate,
    this.onDelete,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _notesController;
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.document?.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.document?.lastName ?? '',
    );
    _notesController = TextEditingController(
      text: widget.document?.notes ?? '',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (widget.document != null) {
      final updatedDocument = Document(
        id: widget.document!.id,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
      widget.onUpdate?.call(updatedDocument);
    } else {
      widget.onCreate(
        _firstNameController.text,
        _lastNameController.text,
        _notesController.text.isEmpty ? null : _notesController.text,
      );
    }
    Navigator.of(context).pop();
  }

  Future<void> _deleteDocument() async {
    if (widget.document == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text('Are you sure you want to delete this document?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      try {
        await _apiService.deleteDocument(widget.document!.id);
        widget.onDelete?.call(widget.document!.id);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete document: ${e.toString()}'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          if (widget.document != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteDocument,
            ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 10,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: const Text('Save'),
                  ),
                ),
                // Add extra padding at the bottom to ensure the save button is always accessible
              ],
            ),
          ),
        ),
      ),
    );
  }
}
