import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simsoft/Widgets/CustomButton.dart';
import 'package:simsoft/Widgets/customTextfield.dart';

class ArticlesManagementPage extends StatefulWidget {
  final String role;
  const ArticlesManagementPage({super.key, required this.role});

  @override
  State<ArticlesManagementPage> createState() => _ArticlesManagementPageState();
}

class _ArticlesManagementPageState extends State<ArticlesManagementPage> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  bool _showForm = true;
  String _searchQuery = '';

  Future<void> _addArticle() async {
    final code = _codeController.text.trim();
    final nom = _nomController.text.trim();
    final description = _descriptionController.text.trim();
    final prix = double.tryParse(_prixController.text.trim()) ?? 0.0;
    final imageUrl = _imageUrlController.text.trim();

    if (code.isEmpty ||
        nom.isEmpty ||
        description.isEmpty ||
        prix <= 0 ||
        imageUrl.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('articles').add({
        'code': code,
        'nom': nom,
        'description': description,
        'prix': prix,
        'image': imageUrl,
        'created_at': Timestamp.now(),
      });

      _codeController.clear();
      _nomController.clear();
      _descriptionController.clear();
      _prixController.clear();
      _imageUrlController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article ajouté avec succès')),
      );
    } catch (e) {
      debugPrint('Erreur ajout article: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }

    setState(() => _isLoading = false);
  }

  Future<void> _deleteArticle(String id) async {
    try {
      await FirebaseFirestore.instance.collection('articles').doc(id).delete();
    } catch (e) {
      debugPrint('Erreur suppression article: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdminOrChef =
        widget.role == 'admin' || widget.role == 'chef d\'equipe';

    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des articles')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (isAdminOrChef)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showForm = !_showForm;
                    });
                  },
                  icon:
                      Icon(_showForm ? Icons.visibility_off : Icons.visibility),
                  label: Text(_showForm
                      ? 'Masquer le formulaire'
                      : 'Afficher le formulaire'),
                ),
              ),
            if (isAdminOrChef && _showForm) ...[
              CustomTextFormField(
                  controller: _codeController,
                  label: 'Code',
                  isPassword: false),
              const SizedBox(height: 10),
              CustomTextFormField(
                  controller: _nomController, label: 'Nom', isPassword: false),
              const SizedBox(height: 10),
              CustomTextFormField(
                  controller: _descriptionController,
                  label: 'Description',
                  isPassword: false),
              const SizedBox(height: 10),
              CustomTextFormField(
                  controller: _prixController,
                  label: 'Prix',
                  isPassword: false),
              const SizedBox(height: 10),
              CustomTextFormField(
                  controller: _imageUrlController,
                  label: 'URL de l\'image',
                  isPassword: false),
              const SizedBox(height: 10),
              const Text(
                'Uploader votre image sur https://postimg.cc et collez ici le lien direct.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              CustomButton(
                buttonColor: _isLoading ? Colors.grey : Colors.black,
                onTap: _isLoading ? () {} : _addArticle,
                label: _isLoading ? 'Ajout en cours...' : 'Ajouter un article',
              ),
              const Divider(height: 32),
            ],
            // Barre de recherche
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher un article',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 16),
            // Affichage des articles
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('articles')
                    .orderBy('created_at', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child:
                            Text("Aucun article disponible pour le moment."));
                  }

                  final docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final nom = data['nom']?.toString().toLowerCase() ?? '';
                    return nom.contains(_searchQuery);
                  }).toList();

                  if (docs.isEmpty) {
                    return const Center(child: Text("Aucun résultat trouvé."));
                  }

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final id = docs[index].id;

                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: data['image'] != null &&
                                      data['image'].toString().isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(
                                        data['image'],
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.image_not_supported,
                                      size: 80),
                            ),
                            const SizedBox(height: 6),
                            Text(data['nom'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(data['description'],
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                            Text('Prix: ${data['prix']} TND'),
                            if (isAdminOrChef)
                              Align(
                                alignment: Alignment.bottomRight,
                                child: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red, size: 20),
                                  onPressed: () => _deleteArticle(id),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
