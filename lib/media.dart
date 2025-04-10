import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reviewall_mobile/reviewall_app.dart';

class MediaListScaffold extends StatefulWidget {
  const MediaListScaffold({super.key});

  @override
  State<MediaListScaffold> createState() => _MediaListScaffoldState();
}

class _MediaListScaffoldState extends State<MediaListScaffold> {
  Key _listKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Mídias'),
        backgroundColor: primaryColor,
      ),
      body: MediaList(key: _listKey), 
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormAddMediaScaffold()),
          );

          if (result == true) {
            // Atualiza a tela após adicionar uma nova mídia
            setState(() {
              _listKey = UniqueKey();
            });
          }
        },
        backgroundColor: primaryColorLight,
        child: const Icon(Icons.add),
      ),
    );
  }
}

Future<dynamic> getMedias() async {
  var url = Uri.parse('$baseUrlApi/media');

  var response = await http.get(url);

  // var response = await Future.delayed(
  //   Duration(seconds: 1),
  //   () => http.Response(
  //     json.encode([
  //       {
  //         "id": "1",
  //         "title": "Interestelar",
  //         "createdAt": "2024-03-28T14:30:00Z",
  //         "genre": "Ficção Científica",
  //         "creator": "Christopher Nolan",
  //         "type": "Filme",
  //         "synopsis": "Um grupo de astronautas viaja através de um buraco de minhoca em busca de um novo lar para a humanidade.",
  //         "releaseDate": "2014-01-01T00:00:00Z"
  //       },
  //       {
  //         "id": "2",
  //         "title": "A Origem",
  //         "createdAt": "2024-03-29T14:30:00Z",
  //         "genre": "Ficção Científica",
  //         "creator": "Christopher Nolan",
  //         "type": "Filme",
  //         "synopsis": "Um ladrão que rouba segredos corporativos através do uso de tecnologia de compartilhamento de sonhos é oferecido a chance de apagar seu passado como pagamento por uma tarefa considerada impossível.",
  //         "releaseDate": "2010-01-01T00:00:00Z"
  //       },
  //       {
  //         "id": "3",
  //         "title": "Breaking Bad",
  //         "createdAt": "2024-03-30T14:30:00Z",
  //         "genre": "Drama",
  //         "creator": "Vince Gilligan",
  //         "type": "Série",
  //         "synopsis": "Um professor de química do ensino médio com câncer terminal começa a fabricar metanfetamina para garantir o futuro financeiro de sua família.",
  //         "releaseDate": "2008-01-20T00:00:00Z"
  //       },
  //       {
  //         "id": "4",
  //         "title": "Planeta Terra",
  //         "createdAt": "2024-03-31T14:30:00Z",
  //         "genre": "Documentário",
  //         "creator": "BBC",
  //         "type": "Documentário",
  //         "synopsis": "Uma série documental que explora a beleza e a diversidade do planeta Terra.",
  //         "releaseDate": "2006-03-05T00:00:00Z"
  //       },
  //       {
  //         "id": "5",
  //         "title": "Naruto",
  //         "createdAt": "2024-04-01T14:30:00Z",
  //         "genre": "Anime",
  //         "creator": "Masashi Kishimoto",
  //         "type": "Anime",
  //         "synopsis": "A história de um jovem ninja que busca reconhecimento e sonha em se tornar o Hokage, o líder de sua vila.",
  //         "releaseDate": "2002-10-03T00:00:00Z"
  //       },
  //       {
  //         "id": "6",
  //         "title": "The Legend of Zelda: Breath of the Wild",
  //         "createdAt": "2024-04-02T14:30:00Z",
  //         "genre": "Aventura",
  //         "creator": "Nintendo",
  //         "type": "Game",
  //         "synopsis": "Um jogo de ação e aventura em um vasto mundo aberto onde o jogador controla Link para salvar o reino de Hyrule.",
  //         "releaseDate": "2017-03-03T00:00:00Z"
  //       },
  //       {
  //         "id": "7",
  //         "title": "1984",
  //         "createdAt": "2024-04-03T14:30:00Z",
  //         "genre": "Distopia",
  //         "creator": "George Orwell",
  //         "type": "Livro",
  //         "synopsis": "Um romance distópico que explora os perigos do totalitarismo e da vigilância governamental.",
  //         "releaseDate": "1949-06-08T00:00:00Z"
  //       },
  //       {
  //         "id": "8",
  //         "title": "Serial Killers",
  //         "createdAt": "2024-04-04T14:30:00Z",
  //         "genre": "Crime",
  //         "creator": "Parcast Network",
  //         "type": "Podcast",
  //         "synopsis": "Um podcast que explora as histórias e as mentes de assassinos em série.",
  //         "releaseDate": "2017-02-15T00:00:00Z"
  //       },
  //       {
  //         "id": "9",
  //         "title": "Bohemian Rhapsody",
  //         "createdAt": "2024-04-05T14:30:00Z",
  //         "genre": "Rock",
  //         "creator": "Queen",
  //         "type": "Música",
  //         "synopsis": "Uma das músicas mais icônicas da banda Queen, conhecida por sua estrutura única e letras enigmáticas.",
  //         "releaseDate": "1975-10-31T00:00:00Z"
  //       }
  //     ]),
  //     200,
  //   ),
  // );

  if (response.statusCode == 200) {
    var data = json.decode(utf8.decode(response.bodyBytes));
    List<Media> medias = (data as List).map((item) => Media.fromJson(item)).toList();
    return medias;
  } else {
    print("Erro ao fazer a requisição: ${response.statusCode}");
    return [];
  }
}

Future<http.Response> postMedia(Map<String, dynamic> media) async {
  var url = Uri.parse('$baseUrlApi/media');
  var response = await http.post(
    url,
    body: json.encode(media),
    headers: {'Content-Type': 'application/json'},
  );
  return response;
}

Future<http.Response> deleteMedia(String id) async {
  var url = Uri.parse('$baseUrlApi/media/$id');
  var response = await http.delete(url);
  return response;
}

class MediaList extends StatelessWidget {
  const MediaList({super.key});

  Future<List<Media>> fetchMedias() async {
    try {
      List<Media> medias = await getMedias();
      // Ordena as mídias pela data de criação em ordem decrescente
      medias.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return medias;
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
        title: RichText(
          text: TextSpan(
            text: media.title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            children: [
              TextSpan(
                text: ' #${media.id}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black54),
              ),
            ],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text('Criador: ${media.creator}'),
            Text('Tipo: ${media.type}'),
            Text('Ano de Lançamento: ${media.releaseDate.year}'),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: media.genre.map<Widget>((genre) {
                return Chip(
                  label: Text(genre),
                  backgroundColor: Colors.grey[200],
                );
              }).toList(),
            ),
          ],
        ),
        leading: Icon(media.icon, size: 40),
        trailing: IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MediaDetailScaffold(media),
              ),
            );
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
  List<dynamic> genre;
  String synopsis;
  DateTime releaseDate;
  IconData icon;

  Media({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.creator,
    required this.type,
    required this.genre,
    required this.synopsis,
    required this.releaseDate,
  }) : icon = _getIconForType(type);

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

  static IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'filme':
        return Icons.movie;
      case 'série':
        return Icons.tv;
      case 'documentário':
        return Icons.book;
      case 'anime':
        return Icons.animation;
      case 'game':
        return Icons.videogame_asset;
      case 'livro':
        return Icons.menu_book;
      case 'podcast':
        return Icons.podcasts;
      case 'música':
        return Icons.music_note;
      default:
        return Icons.device_unknown;
    }
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

// Lista de tipos de mídia
final List<String> sugestTypes = [
  'Filme',
  'Série',
  'Documentário',
  'Anime',
  'Desenho animado',
  'Game',
  'Livro',
  'Podcast',
  'Música',
  'Outro'
];


// Formulário para adicionar uma nova mídia
class FormAddMediaScaffold extends StatefulWidget {
  const FormAddMediaScaffold({super.key});

  @override
  _FormAddMediaScaffoldState createState() => _FormAddMediaScaffoldState();
}

class _FormAddMediaScaffoldState extends State<FormAddMediaScaffold> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para os campos de texto
  final _titleController = TextEditingController();
  final _creatorController = TextEditingController();
  final _typeController = TextEditingController();
  final _genreController = TextEditingController();
  final _synopsisController = TextEditingController();
  final _releaseDateController = TextEditingController();
  
  List<String> _generosSelecionados = [];
  DateTime? _dataLancamento;
  bool _isLoading = false;

  @override
  void dispose() {
    // Liberar recursos dos controladores
    _titleController.dispose();
    _creatorController.dispose();
    _typeController.dispose();
    _genreController.dispose();
    _synopsisController.dispose();
    _releaseDateController.dispose();
    super.dispose();
  }

  Future<void> _salvarMidia() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final midia = {
          'title': _titleController.text,
          'creator': _creatorController.text,
          'type': _typeController.text,
          'genre': _generosSelecionados, // Envia a lista de gêneros
          'synopsis': _synopsisController.text,
          'releaseDate': _dataLancamento!.toIso8601String(),
          'createdAt': DateTime.now().toIso8601String(),
        };

        var response = await postMedia(midia);

        if (response.statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Mídia adicionada com sucesso!')),
            );
            Navigator.pop(context, true);
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
                      controller: _titleController,
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
                      controller: _creatorController,
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
                    
                    DropdownButtonFormField<String>(
                      value: _typeController.text.isEmpty ? null : _typeController.text,
                      decoration: InputDecoration(
                        labelText: 'Tipo',
                        hintText: 'Selecione o tipo',
                        border: OutlineInputBorder(),
                      ),
                      items: sugestTypes.map((String tipo) {
                        return DropdownMenuItem<String>(
                          value: tipo,
                          child: Text(tipo),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _typeController.text = newValue!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o tipo';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                  builder: (context, setDialogState) {
                                    return AlertDialog(
                                      title: Text('Selecione os Gêneros'),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: sugestGeneros.map((String genero) {
                                            return CheckboxListTile(
                                              title: Text(genero),
                                              value: _generosSelecionados.contains(genero),
                                              onChanged: (bool? value) {
                                                setDialogState(() {
                                                  if (value == true) {
                                                    _generosSelecionados.add(genero);
                                                  } else {
                                                    _generosSelecionados.remove(genero);
                                                  }
                                                });
                                              },
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                            setState(() {}); 
                          },
                          icon: Icon(Icons.category),
                          label: Text('Selecionar Gêneros'),
                          style: ElevatedButton.styleFrom(
                            // backgroundColor: primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        
                        SizedBox(height: 8),
                        
                        // Exibe os gêneros selecionados como chips
                        _generosSelecionados.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Selecione pelo menos um gênero',
                                  style: TextStyle(color: Colors.red[700], fontSize: 12),
                                ),
                              )
                            : Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: _generosSelecionados.map((genero) {
                                  return Chip(
                                    label: Text(genero),
                                    backgroundColor: Colors.grey[200],
                                    deleteIcon: Icon(Icons.cancel, size: 18),
                                    onDeleted: () {
                                      setState(() {
                                        _generosSelecionados.remove(genero);
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                        
                        // Campo oculto para validação
                        Opacity(
                          opacity: 0,
                          child: TextFormField(
                            controller: _genreController,
                            validator: (value) {
                              if (_generosSelecionados.isEmpty) {
                                return 'Selecione pelo menos um gênero';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _synopsisController,
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
                            _releaseDateController.text = 
                                "${selectedDate.day.toString().padLeft(2, '0')}/"
                                "${selectedDate.month.toString().padLeft(2, '0')}/"
                                "${selectedDate.year}";
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _releaseDateController,
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


// Visualizar mídia
class MediaDetailScaffold extends StatelessWidget {
  final Media media;

  const MediaDetailScaffold(this.media, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(media.title),
        backgroundColor: primaryColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ícone como imagem principal
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  media.icon,
                  size: 60,
                ),
              ),
              const SizedBox(height: 16),

              // Título
              Text(
                media.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Row of buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Lógica para editar a mídia
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                  ),

                  const SizedBox(width: 8),

                  ElevatedButton.icon(
                    onPressed: () {
                      deleteMedia(media.id).then((response) {
                        if (response.statusCode == 200) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Mídia deletada com sucesso!')),
                          );
                          Navigator.pop(context); // Volta para a lista de mídias
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro ao deletar mídia: ${response.statusCode}')),
                          );
                        }
                      });
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Deletar'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Informações detalhadas
              Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Criador: ${media.creator}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tipo: ${media.type}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gênero: ${media.genre}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sinopse:',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        media.synopsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Data de Lançamento: ${media.releaseDate.day.toString().padLeft(2, '0')}/'
                        '${media.releaseDate.month.toString().padLeft(2, '0')}/'
                        '${media.releaseDate.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}
