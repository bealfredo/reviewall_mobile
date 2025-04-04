import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:reviewall_mobile/resenha_app.dart';


class ReviewListScaffold extends StatelessWidget {
  const ReviewListScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resenhas de Mídias'),
        backgroundColor: secondaryColor,      
        
      ),
      body: ReviewList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FormAddReviewScaffold()),
          );
        },
        backgroundColor: secondaryColorLight,
        child: Icon(Icons.add),
      ),
    );
  }
}

Future<dynamic> getReviews() async {
  var url = Uri.parse('https://67e6f0a56530dbd31111f8e2.mockapi.io/reviewall/review');

  // var response = await http.get(url);
  var response = await Future.delayed(
    Duration(seconds: 1),
    () => http.Response(
      json.encode([
        {
          "id": "1",
          "createdAt": "2024-03-28T14:30:00Z",
          "user": "joao123",
          "rating": 9.5,
          "comment": "Filme incrível, com uma trilha sonora maravilhosa!",
          "mediaId": "interestelar"
        },
        {
          "id": "2",
          "createdAt": "2024-03-29T14:30:00Z",
          "user": "maria456",
          "rating": 8.8,
          "comment": "Uma trama complexa, mas fascinante!",
          "mediaId": "a-origem"
        }
      ]),
      200,
    ),
  );

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    List<Review> reviews = (data as List).map((item) => Review.fromJson(item)).toList();
    return reviews;
  } else {
    print("Erro ao fazer a requisição: ${response.statusCode}");
  }
}

class ReviewList extends StatelessWidget {
  const ReviewList({super.key});

  // getting data from API
  Future<List<Review>> fetchReviews() async {
  try {
    return await getReviews();
  } catch (e) {
    print("Erro ao buscar resenhas: $e");
    return [];
  }
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Review>>(
      future: fetchReviews(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar resenhas'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Nenhuma resenha encontrada'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ReviewListItem(snapshot.data![index]);
            },
          );
        }
      },
    );
  }
}

class ReviewListItem extends StatelessWidget {
  final Review review;

  const ReviewListItem(this.review, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(review.mediaId), // Corrigido de titulo para mediaId
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nota: ${review.rating.toStringAsFixed(1)}'), // Corrigido de nota para rating
            Text('Comentário: ${review.comment}'), // Corrigido de comentario para comment
          ],
        ),
        leading: Icon(Icons.movie),
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

class FormAddReviewScaffold extends StatelessWidget {
  const FormAddReviewScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Resenha'),
        backgroundColor: Colors.redAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Mídia (ID)',
                    hintText: 'Ex: interestelar',
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Usuário',
                    hintText: 'Informe seu nome de usuário',
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Nota',
                    hintText: 'Informe a nota do filme (máximo 10)',
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
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Comentário',
                    hintText: 'Informe sua opinião sobre o filme',
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    // Adicione a lógica para atualizar o estado com a data selecionada
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Data de Criação',
                        hintText: 'Selecione a data',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Lógica para salvar a resenha
            },
            child: Text('Salvar'),
          )
        ],
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