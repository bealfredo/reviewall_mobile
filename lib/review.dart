import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reviewall_mobile/media.dart';

import 'package:reviewall_mobile/reviewall_app.dart';

class ReviewListWidget extends StatefulWidget {
  final Media media;

  const ReviewListWidget({super.key, required this.media});

  @override
  State<ReviewListWidget> createState() => _ReviewListWidgetState();
}

class _ReviewListWidgetState extends State<ReviewListWidget> {
  Future<List<Review>> fetchAndFilterReviews() async {
    try {
      List<Review> reviews = await getReviews();
      return reviews
        .where((review) => review.mediaId == widget.media.id)
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print("Erro ao buscar e filtrar resenhas: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Review>>(
      future: fetchAndFilterReviews(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar resenhas'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Nenhuma resenha encontrada para esta mídia'));
        } else {
          return ReviewList(reviews: snapshot.data!);
        }
      },
    );
  }
}

Future<dynamic> getReviews() async {
  var url = Uri.parse('$baseUrlApi/review');

  var response = await http.get(url);

  if (response.statusCode == 200) {
    var data = json.decode(utf8.decode(response.bodyBytes));
    List<Review> reviews = (data as List).map((item) => Review.fromJson(item)).toList();
    return reviews;
  } else {
    print("Erro ao fazer a requisição: ${response.statusCode}");
  }
}
class ReviewList extends StatelessWidget {
  final List<Review> reviews;

  const ReviewList({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Column(
        children: [
          Center(child: Text('Nenhuma resenha encontrada')),
          SizedBox(height: 80),
        ],
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 80),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          return ReviewListItem(reviews[index]);
        },
      );
    }
  }
}

class ReviewListItem extends StatelessWidget {
  final Review review;

  const ReviewListItem(this.review, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(review.comment),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text('${review.createdAt.day.toString().padLeft(2, '0')}/${review.createdAt.month.toString().padLeft(2, '0')}/${review.createdAt.year} às ${review.createdAt.hour.toString().padLeft(2, '0')}:${review.createdAt.minute.toString().padLeft(2, '0')} - Por ${review.user}'),
          ],
        ),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message),
            SizedBox(height: 4),
            Text(
              review.rating.toStringAsFixed(1),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            // Lógica para deletar a resenha
          },
        ),
      ),
    );
  }
}

class FormAddReviewScaffold extends StatefulWidget {
  final Media media;
  
  const FormAddReviewScaffold({super.key, required this.media});

  @override
  State<FormAddReviewScaffold> createState() => _FormAddReviewScaffoldState();
}

class _FormAddReviewScaffoldState extends State<FormAddReviewScaffold> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para os campos de texto
  final _userController = TextEditingController();
  final _ratingController = TextEditingController();
  final _commentController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    // Liberar recursos dos controladores
    _userController.dispose();
    _ratingController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _salvarResenha() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final review = {
          'mediaId': widget.media!.id,
          'user': _userController.text,
          'rating': double.parse(_ratingController.text),
          'comment': _commentController.text,
          'createdAt': DateTime.now().toIso8601String(), // Gera a data atual automaticamente
        };

        var response = await http.post(
          Uri.parse('$baseUrlApi/review'),
          body: json.encode(review),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Resenha adicionada com sucesso!')),
            );
            Navigator.pop(context, true); // Retorna true para indicar sucesso
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao salvar resenha: ${response.statusCode}')),
            );

            setState(() {
              _isLoading = false;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar resenha: $e')),
          );

          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Resenha'),
        backgroundColor: secondaryColor,
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Exibição da mídia no topo
                  Card(
                    elevation: 2,
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(widget.media.icon, size: 50),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.media.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text('Tipo: ${widget.media.type}'),
                                Wrap(
                                  spacing: 4,
                                  children: widget.media.genre.map((genre) => 
                                    Chip(
                                      label: Text(genre),
                                      labelStyle: TextStyle(fontSize: 12),
                                      padding: EdgeInsets.zero,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    )
                                  ).toList(),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Formulário
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _userController,
                          decoration: InputDecoration(
                            labelText: 'Autor',
                            hintText: 'Informe o nome do autor da resenha',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe o nome do autor';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _ratingController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Nota',
                            hintText: 'Informe a nota (máximo 10)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe a nota';
                            }
                            final nota = double.tryParse(value);
                            if (nota == null) {
                              return 'Valor inválido';
                            }
                            if (nota > 10) {
                              return 'A nota deve ser no máximo 10';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            labelText: 'Comentário',
                            hintText: 'Informe sua opinião sobre a mídia',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe um comentário';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 24),
                        
                        ElevatedButton(
                          onPressed: _salvarResenha,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondaryColor,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: Text(
                            'SALVAR',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}

class Review {
  String id;
  DateTime createdAt;
  String user; 
  double rating;
  String comment;
  String mediaId;

  Review({
    required this.id,
    required this.createdAt,
    required this.user,
    required this.rating,
    required this.comment,
    required this.mediaId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      user: json['user'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
      mediaId: json['mediaId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'user': user,
      'rating': rating,
      'comment': comment,
      'mediaId': mediaId,
    };
  }
}