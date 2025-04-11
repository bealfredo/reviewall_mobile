import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reviewall_mobile/review.dart';
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

Future<http.Response> updateMedia(String id, Map<String, dynamic> media) async {
  var url = Uri.parse('$baseUrlApi/media/$id');
  var response = await http.put(
    url,
    body: json.encode(media),
    headers: {'Content-Type': 'application/json'},
  );
  return response;
}

class MediaList extends StatefulWidget {
  const MediaList({super.key});

  @override
  State<MediaList> createState() => _MediaListState();
}

class _MediaListState extends State<MediaList> {
  late Future<List<Media>> _mediasFuture;

  @override
  void initState() {
    super.initState();
    _mediasFuture = fetchMedias();
  }

  Future<List<Media>> fetchMedias() async {
    try {
      List<Media> medias = await getMedias();

      List<Review> allReviews = await getReviews();

      for (var media in medias) {
        var mediaReviews = allReviews.where((review) => review.mediaId == media.id).toList();

        if (mediaReviews.isNotEmpty) {
          // Calcular a média
          double sum = mediaReviews.fold(0.0, (sum, review) => sum + review.rating);
          media.averageRating = sum / mediaReviews.length;
        } else {
          media.averageRating = 0.0;
        }
      }

      // Ordenar por data de criação
      medias.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return medias;
    } catch (e) {
      print("Erro ao buscar mídias e calcular médias: $e");
      return [];
    }
  }

  void _reloadMediaList() {
    setState(() {
      _mediasFuture = fetchMedias();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Botão de recarregar no topo
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: _reloadMediaList,
            icon: const Icon(Icons.refresh),
            label: const Text('Recarregar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Media>>(
            future: _mediasFuture,
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
                  padding: EdgeInsets.only(bottom: 80),
                  itemBuilder: (context, index) {
                    return MediaListItem(
                      snapshot.data![index],
                      onMediaUpdated: _reloadMediaList,
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class MediaListItem extends StatelessWidget {
  final Media media;
  final VoidCallback onMediaUpdated;

  const MediaListItem(this.media, {required this.onMediaUpdated, super.key});

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
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(media.icon, size: 30),
            Text(
              media.averageRating > 0 ? media.averageRating.toStringAsFixed(1) : "N/A",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: () async {
            final Media? result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MediaDetailScaffold(media.id),
              ),
            );

            if (result != null && result.averageRating != media.averageRating) {
              onMediaUpdated();
            }
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
  double averageRating;
  
  Media({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.creator,
    required this.type,
    required this.genre,
    required this.synopsis,
    required this.releaseDate,
    this.averageRating = 0.0,
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
  final Media? media; // Media opcional para edição
  
  const FormAddMediaScaffold({this.media, super.key});

  @override
  State<FormAddMediaScaffold> createState() => _FormAddMediaScaffoldState();
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
  
  final List<String> _generosSelecionados = [];
  DateTime? _dataLancamento;
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    
    // Verificar se é modo de edição e preencher os campos
    if (widget.media != null) {
      _isEditMode = true;
      _titleController.text = widget.media!.title;
      _creatorController.text = widget.media!.creator;
      _typeController.text = widget.media!.type;
      _synopsisController.text = widget.media!.synopsis;
      
      // Preencher a data
      _dataLancamento = widget.media!.releaseDate;
      _releaseDateController.text = 
        "${_dataLancamento!.day.toString().padLeft(2, '0')}/"
        "${_dataLancamento!.month.toString().padLeft(2, '0')}/"
        "${_dataLancamento!.year}";
      
      // Preencher os gêneros
      _generosSelecionados.addAll(widget.media!.genre.map((g) => g.toString()));
    }
  }

  @override
  void dispose() {
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
        final mediaDados = {
          'title': _titleController.text,
          'creator': _creatorController.text,
          'type': _typeController.text,
          'genre': _generosSelecionados,
          'synopsis': _synopsisController.text,
          'releaseDate': _dataLancamento!.toIso8601String(),
        };
        
        http.Response response;
        
        if (_isEditMode) {
          // Adicionar ID e createdAt para atualização
          mediaDados['id'] = widget.media!.id;
          mediaDados['createdAt'] = widget.media!.createdAt.toIso8601String();
          response = await updateMedia(widget.media!.id, mediaDados);
        } else {
          // Para nova mídia adicionar createdAt
          mediaDados['createdAt'] = DateTime.now().toIso8601String();
          response = await postMedia(mediaDados);
        }

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_isEditMode ? 'Mídia atualizada com sucesso!' : 'Mídia adicionada com sucesso!')),
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
        title: Text(_isEditMode ? 'Editar Mídia' : 'Adicionar Mídia'),
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
                        _isEditMode ? 'ATUALIZAR' : 'SALVAR',
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
class MediaDetailScaffold extends StatefulWidget {
  final String mediaId;

  const MediaDetailScaffold(this.mediaId, {super.key});

  @override
  State<MediaDetailScaffold> createState() => _MediaDetailScaffoldState();
}

class _MediaDetailScaffoldState extends State<MediaDetailScaffold> {
  Key _reviewListKey = UniqueKey();
  late Future<Media> _mediaFuture;
  late List<Review> _filteredReviews;
  bool _isLoading = true;
  late Media _media;

  @override
  void initState() {
    super.initState();
    _mediaFuture = _fetchMediaDetails();
  }

  // Função para buscar os detalhes da mídia pelo ID
  Future<Media> _fetchMediaDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Buscar todas as mídias
      List<Media> allMedias = await getMedias();

      // Encontrar a mídia com o ID correspondente
      Media media = allMedias.firstWhere(
        (m) => m.id == widget.mediaId,
        orElse: () => throw Exception('Mídia não encontrada'),
      );

      // Buscar todas as resenhas
      List<Review> allReviews = await getReviews();

      // Filtrar as resenhas para esta mídia
      _filteredReviews = allReviews.where((review) => review.mediaId == media.id).toList();

      // Calcular a média das avaliações para esta mídia
      if (_filteredReviews.isNotEmpty) {
        double sum = _filteredReviews.fold(0.0, (sum, review) => sum + review.rating);
        media.averageRating = sum / _filteredReviews.length;
      } else {
        media.averageRating = 0.0;
      }

      // Atualizar estado
      if (mounted) {
        setState(() {
          _isLoading = false;
          _media = media;
        });
      }

      return media;
    } catch (e) {
      print("Erro ao buscar detalhes da mídia: $e");

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      throw e;
    }
  }

  // Função para atualizar os dados da mídia
  Future<void> _refreshMediaDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _mediaFuture = _fetchMediaDetails();
      _media = await _mediaFuture;
      _reviewListKey = UniqueKey();
    } catch (e) {
      print("Erro ao atualizar detalhes da mídia: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isLoading ? Text('Carregando...') : Text(_media.title),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, _media);
          },
        ),
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : FutureBuilder<Media>(
            future: _mediaFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && _isLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Erro ao carregar a mídia: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return Center(child: Text(''));
                // return Center(child: Text('Mídia não encontrada'));
              } else {
                _media = snapshot.data!;

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CurrentMedia(
                          media: _media,
                          onMediaUpdated: _refreshMediaDetails,
                        ),
                        const SizedBox(height: 16),

                        // Lista de reviews
                        ReviewListWidget(
                          key: _reviewListKey,
                          reviews: _filteredReviews,
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),

      // Botão flutuante para adicionar resenha
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormAddReviewScaffold(media: _media),
                  ),
                );

                if (result == true) {
                  await _refreshMediaDetails();
                }
              },
              backgroundColor: primaryColorLight,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Resenha'),
            ),
    );
  }
}

class CurrentMedia extends StatelessWidget {
  final Media media;
  final VoidCallback? onMediaUpdated;

  const CurrentMedia({required this.media, this.onMediaUpdated, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Icon(
            media.icon,
            size: 60,
          ),
        ),
        const SizedBox(height: 16),


        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: media.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            children: [
              TextSpan(
                text: ' #${media.id}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        
        // Média de avaliações
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.amber),
            SizedBox(width: 4),
            Text(
              media.averageRating > 0 
                ? "${media.averageRating.toStringAsFixed(1)}/10"
                : "Sem avaliações",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: media.averageRating >= 7 ? Colors.green : 
                      media.averageRating >= 4 ? Colors.amber : 
                      media.averageRating > 0 ? Colors.red : Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Row of buttons
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormAddMediaScaffold(media: media),
                  ),
                );

                if (result == true) {
                  if (onMediaUpdated != null) {
                    onMediaUpdated!();
                  }
                }
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
                    Navigator.pop(context);
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
        SizedBox(
          width: double.infinity,
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Synopsis
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
                  const SizedBox(height: 16),

                  // Genre
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
                  const SizedBox(height: 16), 
                  
                  // Type
                  Text(
                    'Tipo: ${media.type}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),

                  // Creator
                  Text(
                    'Criador: ${media.creator}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                
                  // Release Date
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
        ),
      ],
    );
  }
}