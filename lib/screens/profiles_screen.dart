import 'package:assessment/models/document.dart';
import 'package:assessment/screens/details_screen.dart';
import 'package:assessment/screens/login_screen.dart';
import 'package:assessment/services/api_service.dart';
import 'package:assessment/widgets/shimmer.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class FadeRoute extends PageRouteBuilder {
  final Widget page;
  FadeRoute({required this.page})
    : super(
        pageBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) => page,
        transitionsBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) => FadeTransition(opacity: animation, child: child),
      );
}

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  final _apiService = ApiService();
  List<Document> _documents = [];
  bool _isLoading = false;
  bool _isFirstLoad = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    if (_isLoading) return; // Prevent multiple simultaneous loads

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final documents = await _apiService.searchDocuments();
      if (mounted) {
        setState(() {
          _documents = documents;
          _isLoading = false;
          _isFirstLoad = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _isFirstLoad = false;
        });
      }
    }
  }

  void _optimisticallyUpdateDocument(Document updatedDocument) {
    setState(() {
      final index = _documents.indexWhere(
        (doc) => doc.id == updatedDocument.id,
      );
      if (index != -1) {
        _documents[index] = updatedDocument;
      }
    });
  }

  void _optimisticallyAddDocument(Document newDocument) {
    setState(() {
      _documents = [newDocument, ..._documents];
    });
  }

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      try {
        await _apiService.logout();  // Call API
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout failed: ${e.toString()}')),
          );
        }
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, __, ___) => LoginScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        );
      }
    }


  Widget _buildLoadingList() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer(
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.white),
            title: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            subtitle: Container(
              height: 16,
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDocumentList() {
    final listView = ListView.builder(
      key: ValueKey(_documents.length),
      itemCount: _documents.length,
      itemBuilder: (context, index) {
        final document = _documents[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(document.firstName[0] + document.lastName[0]),
          ),
          title: Text('${document.firstName} ${document.lastName}'),
          subtitle: Text(
            document.notes ?? 'No notes',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DetailsScreen(
                  document: document,
                  onCreate: (_, __, ___) {}, // Not used in edit mode
                  onUpdate: (updatedDocument) async {
                    // Optimistically update the document
                    _optimisticallyUpdateDocument(updatedDocument);
                    
                    try {
                      // Update the document on the server
                      await _apiService.updateDocument(updatedDocument);
                      // Refresh the list to confirm the changes
                      _loadDocuments();
                    } catch (e) {
                      // Revert the optimistic update if the server update failed
                      _loadDocuments();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to update document: ${e.toString()}',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  onDelete: (documentId) {
                    // Optimistically remove the document
                    setState(() {
                      _documents.removeWhere((doc) => doc.id == documentId);
                    });
                  },
                ),
              ),
            );
          },
        );
      },
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child:
          _documents.isEmpty && _isFirstLoad
              ? _buildLoadingList()
              : _documents.isEmpty
              ? const Center(child: Text('No documents found'))
              : kIsWeb
              ? listView
              : RefreshIndicator(onRefresh: _loadDocuments, child: listView),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Profiles'),
            if (_isLoading) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ],
        ),
        centerTitle: true,
        actions: [
          if (kIsWeb)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading ? null : _loadDocuments,
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => DetailsScreen(
                    onCreate: (firstName, lastName, notes) async {
                      // Create a temporary document with a placeholder ID
                      final tempDocument = Document(
                        id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
                        firstName: firstName,
                        lastName: lastName,
                        notes: notes,
                      );

                      // Optimistically add the new document
                      _optimisticallyAddDocument(tempDocument);

                      try {
                        // Create the document on the server
                        await _apiService.createDocument(
                          firstName,
                          lastName,
                          notes,
                        );
                        // Refresh the list to get the real document with proper ID
                        _loadDocuments();
                      } catch (e) {
                        // Remove the temporary document if creation failed
                        setState(() {
                          _documents.removeWhere(
                            (doc) => doc.id == tempDocument.id,
                          );
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to create document: ${e.toString()}',
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body:
          _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: $_error',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadDocuments,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _buildDocumentList(),
    );
  }
}
