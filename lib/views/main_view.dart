import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/blocs/notes/notes.dart';
import 'package:notes/blocs/notes/notes_bloc.dart';
import 'package:notes/database_helper/database_helper.dart';
import 'package:notes/database_tables_models/database_tables_models.dart';
import 'package:intl/intl.dart';
import 'package:notes/models/models.dart';
import 'package:notes/views/custom_popup_menu_button/custom_popup_menu_button.dart';
import 'package:notes/views/search_notes/search_notes.dart';

import 'navigation_drawer/navigation_drawer.dart';
import 'note_detail_view.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin{

  bool _isGridUI;
  bool _isAdding;
  bool _hasText;

  FocusNode _focusNode;

  TextEditingController _tEController;
  
  DatabaseHelper _databaseHelper = DatabaseHelper();

  List<Notes> selectedNotes = [];


  @override
  void initState() {
    super.initState();
    _isGridUI = false;
    _isAdding =false;
    _hasText = false;
    _focusNode = FocusNode();
    _tEController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      drawer: NavigationDrawer(),
      body: Stack(
        children: [
          BlocBuilder(
            bloc: BlocProvider.of<NotesBloc>(context),
              builder: (context, state){
                if(state is NotesLoaded){
                  return Container(
                      child :
                      _isGridUI
                          ? Container(
                          child: GridView.count(
                            padding: EdgeInsets.all(15.00),
                            physics: BouncingScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 15.00,
                            mainAxisSpacing: 15.00,
                            scrollDirection: Axis.vertical,
                            children: List.generate(
                                state.notes.length, (index) {
                              return Material(
                                animationDuration: Duration(seconds: 1),
                                color: index.isEven ? Theme.of(context).primaryColorDark.withOpacity(0.5) : Theme.of(context).primaryColorLight.withOpacity(0.5),
                                borderRadius: BorderRadius.all(Radius.circular(5.00)),
                                child: InkWell(
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width / 2.7,
                                        height: MediaQuery.of(context).size.height / 3,
                                        padding: EdgeInsets.all(10.00),
                                        decoration: BoxDecoration(
                                          //color: index.isEven ? Colors.orange[200] : Colors.blue[200],
                                          borderRadius: BorderRadius.all(Radius.circular(5.00)),
                                          //boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2.00, spreadRadius: 3.00)]
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                child: Hero(
                                                    tag: index,
                                                    transitionOnUserGestures: true,
                                                    flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
                                                      return DefaultTextStyle(
                                                          style: DefaultTextStyle.of(toHeroContext).style,
                                                          child: toHeroContext.widget
                                                      );
                                                    },
                                                    child: Text(
                                                        "${state.notes[index].title}",
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 20.00
                                                        ),
                                                        overflow: TextOverflow.ellipsis
                                                    )
                                                )
                                            ),
                                            SizedBox(height: 5.00),
                                            Expanded(
                                                child: Container(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text(
                                                        "${state.notes[index].content}",
                                                        style: TextStyle(
                                                            color: Colors.blueGrey,
                                                            fontSize: 18.00
                                                        ),
                                                        overflow: TextOverflow.clip
                                                    )
                                                )
                                            ),
                                            SizedBox(height: 5.00),
                                            Container(
                                                child: Text(
                                                    DateFormat("dd MMM hh:mm a").format(DateFormat("dd MMM yyyy hh:mm:ss:a").parse(state.notes[index].dateModified)),
                                                    style: TextStyle(
                                                        color: Colors.blueGrey
                                                    ), overflow: TextOverflow.ellipsis,
                                                )
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.topRight,
                                        child: IconButton(icon: state.notes[index].favorite == "no" ? Icon( Icons.favorite_border, color: Colors.blueGrey) : Icon(Icons.favorite, color: Theme.of(context).primaryColor),  onPressed: () {
                                          Notes notes = Notes.updateFavoriteStatus(state.notes[index].id, state.notes[index].favorite == "no" ? "yes" : "no");
                                          BlocProvider.of<NotesBloc>(context).add(UpdateFavoriteStatus(notes: notes, columnName: Notes.columnDateModified, order: Order.descending));
                                        }),
                                      )
                                    ],
                                  ),
                                  onTap: () {
                                    //_animationController.repeat(reverse: true);
                                    Future.delayed(Duration(milliseconds: 200),
                                            () => _gridInkWellOnTap(state.notes[index], index.isEven ? Theme.of(context).primaryColorDark : Theme.of(context).primaryColorLight, index)
                                    );
                                  },
                                ),
                              );
                            }
                            ),
                          )
                      )
                          : Container(
                        child: ListView.separated(
                            padding: EdgeInsets.all(15.00),
                            physics: BouncingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              return Material(
                                color: index.isEven
                                    ? Theme.of(context).primaryColorDark.withOpacity(0.5)
                                    : Theme.of(context).primaryColorLight.withOpacity(0.5),
                                borderRadius: BorderRadius.all(Radius.circular(5.00)),
                                child: InkWell(
                                  borderRadius: BorderRadius.all(Radius.circular(5.00)),
                                  child: Stack(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10.00),
                                        height: MediaQuery.of(context).size.height / 6,
                                        decoration: BoxDecoration(
                                          //color: index.isEven ? Colors.orange[200] : Colors.blue[200],
                                          borderRadius: BorderRadius.all(Radius.circular(5.00)),
                                          //boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2.00, spreadRadius: 3.00)]
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                child: Hero(
                                                    tag: index,
                                                    transitionOnUserGestures: true,
                                                    flightShuttleBuilder: (flightContext,
                                                        animation,
                                                        flightDirection,
                                                        fromHeroContext,
                                                        toHeroContext) {
                                                      return DefaultTextStyle(
                                                          style: DefaultTextStyle.of(toHeroContext)
                                                              .style,
                                                          child: toHeroContext.widget);
                                                    },
                                                    child: Text("${state.notes[index].title}",
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 20.00
                                                        )
                                                    )
                                                )
                                            ),
                                            Container(
                                                child: Text(
                                                  "${state.notes[index].content}",
                                                  style: TextStyle(
                                                      color: Colors.blueGrey,
                                                      fontSize: 18.00
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                )),
                                            Container(
                                                child: Text(
                                                    DateFormat("dd MMM hh:mm a").format(
                                                        DateFormat("dd MMM yyyy hh:mm:ss:a")
                                                            .parse(state.notes[index].dateModified)),
                                                    style: TextStyle(color: Colors.blueGrey
                                                    )
                                                )
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.topRight,
                                        child: IconButton(icon: state.notes[index].favorite == "no" ? Icon( Icons.favorite_border, color: Colors.blueGrey,) : Icon(Icons.favorite, color: Theme.of(context).primaryColor),  onPressed: () {
                                          Notes notes = Notes.updateFavoriteStatus(state.notes[index].id, state.notes[index].favorite == "no" ? "yes" : "no");
                                          BlocProvider.of<NotesBloc>(context).add(UpdateFavoriteStatus(notes: notes, columnName: Notes.columnDateModified, order: Order.descending));
                                        }),
                                      )
                                    ],
                                  ),
                                  onTap: () async{
                                    bool isDeleted = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => NoteDetailView(notes: state.notes[index], color: index.isEven
                                        ? Theme.of(context).primaryColorDark
                                        : Theme.of(context).primaryColorLight, index: index)));
                                    if(isDeleted ?? false) {
                                      setState(() {
                                        isDeleted = false;
                                      });
                                    }
                                  },
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox(height: 10.00);
                            },
                            itemCount: state.notes.length),
                      )
                  );
                }
                else if (state is NotesLoading){
                  return _notesLoadingWidget(context);
                }
                else if (state is ZeroNotesFound) {
                  return _zeroNotesFoundWidget(context, state);
                }
                else if (state is Failure) {
                  return _failureWidget(context, state);
                }
                else {
                  return _circularProgressIndicator(context);
                }
              }
          ),
          Visibility(visible: (_isAdding), child: Container(
            alignment: Alignment.bottomCenter,
            child: TextField(
              decoration: InputDecoration(
                fillColor: Colors.grey[100],
                filled: true,
                suffixIcon: Visibility(visible: _hasText,child: IconButton(icon: Icon(Icons.clear, color: Colors.blueGrey), onPressed: () {
                  _tEController.clear();
                  setState(() {
                    _hasText = false;
                  });
                }))
              ),
              autofocus: true,
              focusNode: _focusNode,
              controller: _tEController,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,
              maxLengthEnforced: true,
              textCapitalization: TextCapitalization.sentences,
              maxLines: null,
              onSubmitted: (value) async{
                if(value.isNotEmpty) {
                  Notes notes = Notes(
                    DateFormat("dd MMM yyyy hh:mm:ss:a").format(DateTime.now()),
                    "${value.contains(" ") ? "${value.split(" ")[0]} ${value.split(" ")[1]}" : "${value.split(" ")[0]}"}",
                    value,
                    DateFormat("dd MMM yyyy hh:mm:ss:a").format(DateTime.now()),
                    "no"
                  );
                  BlocProvider.of<NotesBloc>(context).add(AddNote(notes: notes, columnName: Notes.columnDateModified, order: Order.descending));
                  _tEController.clear();
                }
              },
              onChanged: (value) {
                if(value.isNotEmpty) {
                  setState(() {
                    _hasText = true;
                  });
                }
              },
              onEditingComplete: () {
                setState(() {
                  _isAdding = false;
                });
              },
            ),
          )),
        ],
      ),
      floatingActionButton: _floatingActionButton(context),
    );
  }

  void _gridInkWellOnTap(Notes note, Color color, int index) async{
    //_animationController.stop();
    bool isDeleted = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => NoteDetailView(notes: note, color: color, index: index)));
    if(isDeleted ?? false) {
      setState(() {
        isDeleted = false;
      });
    }
  }


  @override
  void dispose() {
    _tEController.dispose();
    super.dispose();
  }

  Widget _notesLoadingWidget(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.blue)
        )
    );
  }

  Widget _zeroNotesFoundWidget(BuildContext context, ZeroNotesFound state) {
    return Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.style, color: Colors.blue, size: 50.00),
              SizedBox(height: 15.00),
              Text(state.message, style: TextStyle(color: Colors.blue, fontSize: 25.00)),
            ],
        )
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      title: Text("Notes"),
      actions: <Widget>[
        IconButton(
            icon: Icon(
                _isGridUI
                    ? Icons.list
                    : Icons.apps, color: Colors.white70
            ),
            onPressed: () {
              setState(() {
                _isGridUI = !_isGridUI;
              });
            }),
        IconButton(icon: Icon(Icons.search), onPressed: ()async{
          List<Notes> list = await _databaseHelper.getAllNotes();
          await showSearch<Notes>(
              context: context,
              delegate: SearchNotes(bloc: BlocProvider.of<NotesBloc>(context), list: list)
          );
        }),
        CustomPopupMenuButton()
      ],
    );
  }

  Visibility _floatingActionButton(BuildContext context) {
    return Visibility(
      visible: (!_isAdding),
      child: FloatingActionButton(
          heroTag: "fab",
          tooltip: 'Add New Note',
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(Icons.add),
          onPressed: () {
            setState(() {
              _isAdding = true;
            });
          }),
    );
  }

  Widget _failureWidget(BuildContext context, Failure state) {
    return Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, color: Theme.of(context).primaryColor, size: 50.00),
              SizedBox(height: 15.00),
              Text(state.message, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 25.00)),
            ],
        ));
  }

  Widget _circularProgressIndicator(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
            strokeWidth: 2.00
        )
    );
  }

}
