import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fibonacci Scroll',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FibonacciScrollView(),
    );
  }
}

class FibonacciScrollView extends StatefulWidget {
  const FibonacciScrollView({super.key});

  @override
  _FibonacciScrollViewState createState() => _FibonacciScrollViewState();
}

class _FibonacciScrollViewState extends State<FibonacciScrollView> {
  final List<int> fibonacciNumbers = [];
  final List<Map<String, dynamic>> mainList = [];
  final List<Map<String, dynamic>> hiddenItems = [];
  final ScrollController _scrollController = ScrollController();
  int? _highlightedIndex;
  Map<String, dynamic>? _lastHiddenItem;

  @override
  void initState() {
    super.initState();
    generateFibonacci(40);
  }

  void generateFibonacci(int n) {
    List<int> fibonacciNumbers = [0, 1];
    for (int i = 2; i <= n; i++) {
      fibonacciNumbers.add(fibonacciNumbers[i - 1] + fibonacciNumbers[i - 2]);
    }

    setState(() {
      for (int i = 0; i < fibonacciNumbers.length; i++) {
        mainList.add({
          'index': i,
          'number': fibonacciNumbers[i],
          'icon': getIconForIndex(i),
        });
      }
    });
  }

  IconData getIconForIndex(int index) {
    final List<IconData> baseIcons = [
      Icons.circle,
      Icons.close,
      Icons.close,
      Icons.square,
      Icons.circle,
      Icons.square,
      Icons.square,
      Icons.close,
    ];
    return baseIcons[index % baseIcons.length];
  }

  void showBottomSheet(BuildContext context, {IconData? icon}) {
    List<Map<String, dynamic>> filteredItems = hiddenItems;

    if (icon != null) {
      filteredItems =
          hiddenItems.where((item) => item['icon'] == icon).toList();
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: ListView.builder(
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              bool isLastHiddenItem = filteredItems[index] == _lastHiddenItem;
              return ListTile(
                title: Text(
                  'Number: ${filteredItems[index]['number']}',
                ),
                subtitle: Text('index: ${filteredItems[index]['index']}'),
                trailing: Icon(
                  icon == filteredItems[index]['icon']
                      ? filteredItems[index]['icon']
                      : Icons.square,
                ),
                tileColor: isLastHiddenItem ? Colors.green : Colors.transparent,
                onTap: () {
                  setState(() {
                    int originalIndex = filteredItems[index]['index'];
                    mainList.insert(originalIndex, filteredItems[index]);
                    hiddenItems.remove(filteredItems[index]);
                    _highlightedIndex = originalIndex;
                  });
                  Navigator.pop(context);
                  _scrollToHighlightedItem();
                },
              );
            },
          ),
        );
      },
    );
  }

  void _handleIconTap(int index, IconData icon) {
    setState(() {
      _lastHiddenItem = mainList[index];
      hiddenItems.add(mainList[index]);
      mainList.removeAt(index);
    });

    if (icon == Icons.circle || icon == Icons.close) {
      showBottomSheet(context, icon: icon);
    } else if (icon == Icons.square) {
      showBottomSheet(context);
    }

    _scrollToHighlightedItem();
  }

  void _scrollToHighlightedItem() {
    if (_highlightedIndex != null) {
      _scrollController.animateTo(
        _highlightedIndex! * 72.0,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HOME'),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: mainList.length,
        itemBuilder: (context, index) {
          return ListTile(
            trailing: GestureDetector(
              onTap: () => _handleIconTap(index, mainList[index]['icon']),
              child: Icon(mainList[index]['icon']),
            ),
            title: Text(
              'index : ${mainList[index]['index']} Number : ${mainList[index]['number']}',
            ),
            tileColor:
                _highlightedIndex == index ? Colors.red : Colors.transparent,
          );
        },
      ),
    );
  }
}
