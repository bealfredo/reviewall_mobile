import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

const primaryColor = Color.fromARGB(255, 102, 255, 82);
const primaryColorLight = Color.fromARGB(255, 102, 255, 82);
const secondaryColor = Color.fromARGB(255, 255, 82, 82);


class MediaListScaffold extends StatelessWidget {
  const MediaListScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Mídias'),
        backgroundColor: primaryColor,      
        
      ),
      body: MediaList(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FormAddMediaScaffold()),
          );
        },
        backgroundColor: primaryColorLight,
        child: Icon(Icons.add),
      ),
    );
  }
}

Future<dynamic> getMedias() async {
  var url = Uri.parse('https://67e6f0a56530dbd31111f8e2.mockapi.io/resenhal/media');

  var response = await Future.delayed(
    Duration(seconds: 1),
    () => http.Response(
      json.encode([
        {
          "id": "1",
          "title": "Interestelar",
          "createdAt": "2024-03-28T14:30:00Z",
          "genre": "Ficção Científica",
          "creator": "Christopher Nolan",
          "type": "Filme",
          "synopsis": "Um grupo de astronautas viaja através de um buraco de minhoca em busca de um novo lar para a humanidade.",
          "releaseDate": "2014-01-01T00:00:00Z"
        },
        {
          "id": "2",
          "title": "A Origem",
          "createdAt": "2024-03-29T14:30:00Z",
          "genre": "Ficção Científica",
          "creator": "Christopher Nolan",
          "type": "Filme",
          "synopsis": "Um ladrão que rouba segredos corporativos através do uso de tecnologia de compartilhamento de sonhos é oferecido a chance de apagar seu passado como pagamento por uma tarefa considerada impossível.",
          "releaseDate": "2010-01-01T00:00:00Z"
        }
      ]),
      200,
    ),
  );

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    List<Media> medias = (data as List).map((item) => Media.fromJson(item)).toList();
    return medias;
  } else {
    print("Erro ao fazer a requisição: ${response.statusCode}");
  }
}

Future<http.Response> postMedia(Map<String, dynamic> media) async {
  var url = Uri.parse('https://67e6f0a56530dbd31111f8e2.mockapi.io/resenhal/media');
  var response = await http.post(
    url,
    body: json.encode(media),
    headers: {'Content-Type': 'application/json'},
  );
  return response;
}

class MediaList extends StatelessWidget {
  const MediaList({super.key});

  Future<List<Media>> fetchMedias() async {
    try {
      return await getMedias();
    } catch (e) {
      print("Erro ao buscar mídias: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Media>>(
      future: fetchMedias(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar mídias'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Nenhuma mídia encontrada'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return MediaListItem(snapshot.data![index]);
            },
          );
        }
      },
    );
  }
}

class MediaListItem extends StatelessWidget {
  final Media media;

  const MediaListItem(this.media, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(media.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Criador: ${media.creator}'),
            Text('Tipo: ${media.type}'),
            Text('Gênero: ${media.genre}'),
            Text('Ano de Lançamento: ${media.releaseDate.year}'),
          ],
        ),
        leading: Icon(Icons.movie),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            
          },
        ),
      ),
    );
  }
}


class Media {
  String id;
  DateTime createdAt;
  String title; 
  String creator;
  String type;
  String genre;
  String synopsis;
  DateTime releaseDate;

  Media({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.creator,
    required this.type,
    required this.genre,
    required this.synopsis,
    required this.releaseDate,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      title: json['title'],
      creator: json['creator'],
      type: json['type'],
      genre: json['genre'],
      synopsis: json['synopsis'],
      releaseDate: DateTime.parse(json['releaseDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'title': title,
      'creator': creator,
      'type': type,
      'genre': genre,
      'synopsis': synopsis,
      'releaseDate': releaseDate.toIso8601String(),
    };
  }
}

// Lista de gêneros
final List<String> sugestGeneros = [
  'Ação',
  'Anime',
  'Asiáticos',
  'Brasileiros',
  'Britânicos',
  'Ciência e natureza',
  'Comédia',
  'Drama',
  'Esportes',
  'EUA',
  'Ficção científica e fantasia',
  'Mistério',
  'Mulheres em ação',
  'Novelas',
  'Para as crianças',
  'Policiais',
  'Reality e talk shows',
  'Romance',
  'Séries documentais',
  'Teen',
  'Terror',
  'Outro'
];


class FormAddMediaScaffold extends StatefulWidget {
  const FormAddMediaScaffold({super.key});

  @override
  _FormAddMediaScaffoldState createState() => _FormAddMediaScaffoldState();
}

class _FormAddMediaScaffoldState extends State<FormAddMediaScaffold> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para os campos de texto
  final _tituloController = TextEditingController();
  final _criadorController = TextEditingController();
  final _tipoController = TextEditingController();
  final _generoController = TextEditingController();
  final _sinopseController = TextEditingController();
  final _dataLancamentoController = TextEditingController();
  
  DateTime? _dataLancamento;
  bool _isLoading = false;

  @override
  void dispose() {
    // Liberar recursos dos controladores
    _tituloController.dispose();
    _criadorController.dispose();
    _tipoController.dispose();
    _generoController.dispose();
    _sinopseController.dispose();
    _dataLancamentoController.dispose();
    super.dispose();
  }

  Future<void> _salvarMidia() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final midia = {
          'title': _tituloController.text,
          'creator': _criadorController.text,
          'type': _tipoController.text,
          'genre': _generoController.text,
          'synopsis': _sinopseController.text,
          'releaseDate': _dataLancamento!.toIso8601String(),
          'createdAt': DateTime.now().toIso8601String(),
        };

        var response = await postMedia(midia);

        if (response.statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Mídia adicionada com sucesso!')),
            );
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao salvar mídia: ${response.statusCode}')),
            );

            setState(() {
            _isLoading = false;
          });
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar mídia: $e')),
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
        title: Text('Adicionar Mídia'),
        backgroundColor: primaryColor,        
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _tituloController,
                      decoration: InputDecoration(
                        labelText: 'Título',
                        hintText: 'Ex: Interestelar',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o título';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _criadorController,
                      decoration: InputDecoration(
                        labelText: 'Criador',
                        hintText: 'Ex: Christopher Nolan',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o criador';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _tipoController,
                      decoration: InputDecoration(
                        labelText: 'Tipo',
                        hintText: 'Ex: Filme',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o tipo';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _generoController,
                      decoration: InputDecoration(
                        labelText: 'Gênero',
                        hintText: 'Ex: Ficção Científica',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o gênero';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _sinopseController,
                      decoration: InputDecoration(
                        labelText: 'Sinopse',
                        hintText: 'Informe a sinopse do filme',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe a sinopse';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    GestureDetector(
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: _dataLancamento ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        
                        if (selectedDate != null) {
                          setState(() {
                            _dataLancamento = selectedDate;
                            _dataLancamentoController.text = 
                                "${selectedDate.day.toString().padLeft(2, '0')}/"
                                "${selectedDate.month.toString().padLeft(2, '0')}/"
                                "${selectedDate.year}";
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _dataLancamentoController,
                          decoration: InputDecoration(
                            labelText: 'Data de Lançamento',
                            hintText: 'Selecione a data',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecione a data de lançamento';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    ElevatedButton(
                      onPressed: _salvarMidia,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'SALVAR',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
