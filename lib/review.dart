import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reviewall_mobile/models/media_model.dart';
import 'package:reviewall_mobile/models/review_model.dart';

import 'package:reviewall_mobile/reviewall_app.dart';
import 'package:reviewall_mobile/services/review_service.dart';

class ReviewListWidget extends StatelessWidget {
  final List<Review> reviews;
  final VoidCallback? onReviewDeleted;

  const ReviewListWidget({super.key, required this.reviews, this.onReviewDeleted});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Center(child: Text('Nenhuma resenha encontrada para esta mídia'));
    } else {
      // Ordena as resenhas em ordem decrescente pela data de criação
      List<Review> sortedReviews = List.from(reviews)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return ReviewList(reviews: sortedReviews, onReviewDeleted: onReviewDeleted);
    }
  }
}

class ReviewList extends StatelessWidget {
  final List<Review> reviews;
  final VoidCallback? onReviewDeleted;

  const ReviewList({required this.reviews, this.onReviewDeleted, super.key});

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
          return ReviewListItem(
            reviews[index],
            onReviewDeleted: onReviewDeleted,
          );
        },
      );
    }
  }
}

class ReviewListItem extends StatelessWidget {
  final Review review;
  final VoidCallback? onReviewDeleted;

  const ReviewListItem(this.review, {this.onReviewDeleted, super.key});

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
          onPressed: () async {
            final currentContext = context;
            
            // Mostrar diálogo de confirmação
            final shouldDelete = await showDialog<bool>(
              context: currentContext,
              builder: (dialogContext) => AlertDialog(
                title: Text('Confirmar exclusão'),
                content: Text('Deseja realmente excluir esta resenha?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: Text('Excluir'),
                  ),
                ],
              ),
            );
            
            if (!currentContext.mounted || shouldDelete != true) return;
            
            try {
              ScaffoldMessenger.of(currentContext).showSnackBar(
                SnackBar(content: Text('Excluindo resenha...'), duration: Duration(seconds: 1)),
              );
              
              await deleteReview(review.id);
              
              if (!currentContext.mounted) return;
              
              ScaffoldMessenger.of(currentContext).showSnackBar(
                SnackBar(content: Text('Resenha excluída com sucesso!')),
              );
              
              if (onReviewDeleted != null) {
                onReviewDeleted!();
              }
            } catch (e) {
              if (!currentContext.mounted) return;
              
              ScaffoldMessenger.of(currentContext).showSnackBar(
                SnackBar(
                  content: Text('Erro ao excluir resenha: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
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

        var response = await postReview(review);

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
        title: Text('Adicionar Resenha', style: TextStyle(color: fontColor)),
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: fontColor),
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
                            backgroundColor: primaryColor,
                            foregroundColor: fontColor,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            disabledBackgroundColor: secondaryColor,
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

