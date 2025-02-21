import 'dart:js_interop';

import 'package:flutter/material.dart';
import "package:universal_html/html.dart" as html;
import 'package:web/web.dart' as web;

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}


/// Application itself.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: const HomePage()
    );
  }
}

/// [Widget] displaying the home page consisting of an image the the buttons.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State of a [HomePage].
class _HomePageState extends State<HomePage> {
  final TextEditingController _url = TextEditingController();
  bool _isActiveButton = false;
  bool _isDarkened = false;
  String? _selectedValue;
  
  // Called after `element` is attached to the DOM.
  void onElementAttached(web.HTMLDivElement element) {
    final web.Element? located = web.document.querySelector('#someIdThatICanFindLater');
    assert(located == element, 'Wrong `element` located!');
    // Do things with `element` or `located`, or call your code now...
    element.style.backgroundColor = 'green';
  }

  void onElementCreated(Object element) {
    element as web.HTMLDivElement;
    element.id = 'someIdThatICanFindLater';

    // Create the observer
    final web.ResizeObserver observer = web.ResizeObserver((
      JSArray<web.ResizeObserverEntry> entries,
      web.ResizeObserver observer,
    ) {
      if (element.isConnected) {
        // The observer is done, disconnect it.
        observer.disconnect();
        // Call our callback.
        onElementAttached(element);
      }
    }.toJS);

    // Connect the observer.
    observer.observe(element);
  }

  void _addImageToHtml(String url) {
    if (url.isNotEmpty) {
      var container = html.document.getElementById('someIdThatICanFindLater');
      container?.innerHtml = '';
      
      var imageElement = html.ImageElement()
      ..src = url
      ..alt = 'Image from URL'
      ..id = 'Image';

      imageElement.onDoubleClick.listen((event) {
        _toggleFullscreen();
      });

      imageElement.style.width = '100%';
      imageElement.style.height = '100%'; 

      container?.append(imageElement);
    }
  }

  // Функция для переключения полноэкранного режима
  void _toggleFullscreen() {
    // Получаем текущий элемент в полноэкранном режиме
    var fullscreenElement = html.document.fullscreenElement;
    var image = html.document.getElementById('Image');

    if (fullscreenElement == null) {
      // Переходим в полноэкранный режим
      image?.requestFullscreen();
    } else {
      // Выход из полноэкранного режима
      html.document.exitFullscreen();
    }
  }

  void _checkIfButtonShouldBeEnabled(String text) {
    setState(() {
      _isActiveButton = text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:HtmlElementView.fromTagName(
                        tagName: 'div',
                        onElementCreated: (element) => onElementCreated(element),
                      )
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(hintText: 'Image URL'),
                        controller: _url,
                        onChanged: _checkIfButtonShouldBeEnabled,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _isActiveButton ? () => _addImageToHtml(_url.text) : null,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                        child: Icon(Icons.arrow_forward),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
          if (_isDarkened)
            ColorFiltered(
              colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.darken),
              child: ModalBarrier(dismissible: false, color: Colors.transparent),
            ),
        ],
      ), 
      floatingActionButton: PopupMenuButton<String>(
        offset: Offset(0, -120),
        child:Container(
          width: 56.0,
          height: 56.0,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.menu,
            size: 26.0,
            color: Colors.white,
          ),
        ),
        onCanceled: () {
          setState(() {
            _isDarkened = false;
          });
        },
        onOpened: () {
          setState(() {
            _isDarkened = true;
          });
        },
        onSelected: (value) {
          // Обработать выбор
          if (value == 'Enter fullscreen') {
            _toggleFullscreen();
            setState(() {
              _selectedValue = value;
              _isDarkened = false;
            });
          } else {
            setState(() {
              _selectedValue = value;
              _isDarkened = false;
            });
            html.document.exitFullscreen();
          }
        },
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              value: 'Enter fullscreen',
              child: Text('Enter fullscreen'),
            ),
            PopupMenuItem(
              value: 'Exit fullscreen',
              child: Text('Exit fullscreen'),
            ),
          ];
        },
      ),
    );
  }
}
