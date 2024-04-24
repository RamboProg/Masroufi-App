import 'package:flutter/material.dart';
import 'ExlistWidget.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'NewExWidget.dart';
import 'Expense.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final firestore = FirebaseFirestore.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: mainPageHook(),
    );
  }
}

class mainPage extends StatefulWidget {
  const mainPage({super.key});

  @override
  State<mainPage> createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {
  final List<Expense> allExpenses = [];
  void addnewExpense({
    required String t,
    required double a,
    required DateTime d,
  }) async {
    final expense =
        Expense(amount: a, date: d, id: DateTime.now().toString(), title: t);
    try {
      await firestore.collection('expenses').add(expense.toMap());
      setState(() {
        allExpenses.add(expense);
      });
      Navigator.of(context).pop();
    } catch (error) {
      // Handle errors appropriately (e.g., show a snackbar to the user)
      print(error.toString());
    }
  }

  void deleteExpense({required String id}) async {
    try {
      // Find the document to delete in Firestore
      final docRef = firestore.collection('expenses').doc(id);

      // Delete the document from Firestore
      await docRef.delete();

      // Update the local list (optional, as data might be fetched from Firestore later)
      setState(() {
        allExpenses.removeWhere((e) => e.id == id);
      });
    } catch (error) {
      // Handle errors appropriately (e.g., show a snackbar to the user)
      print(error.toString());
    }
  }

  double calculateTotal() {
    double total = 0;
    allExpenses.forEach((e) {
      total += e.amount;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (b) {
                return ExpenseForm(addnew: addnewExpense);
              });
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (b) {
                      return ExpenseForm(addnew: addnewExpense);
                    });
              },
              icon: Icon(Icons.add))
        ],
        title: Text('Masroufi'),
      ),
      body: ListView(
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(10),
            height: 100,
            child: Card(
              elevation: 5,
              child: Center(
                  child: Text(
                'EGP ' + calculateTotal().toString(),
                style: TextStyle(fontSize: 30),
              )),
            ),
          ),
          EXListWidget(allExpenses: allExpenses, deleteExpense: deleteExpense),
        ],
      ),
    );
  }
}

//-----------------------(Hook version)-----------------------------
class mainPageHook extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final ValueNotifier<List<Expense>> allExpenses =
        useState<List<Expense>>([]);
    var context = useContext();
    void addnewExpense(
        {required String t, required double a, required DateTime d}) {
      allExpenses.value = [
        ...allExpenses.value,
        Expense(amount: a, date: d, id: DateTime.now().toString(), title: t)
      ];

      Navigator.of(context).pop();
    }

    void deleteExpense({required String id}) {
      allExpenses.value = [
        ...?(allExpenses.value as List<Expense>)
          ..removeWhere((e) {
            return e.id == id;
          })
      ];
    }

    double calculateTotal() {
      double total = 0;
      allExpenses.value.forEach((e) {
        total += e.amount;
      });
      return total;
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (b) {
                return ExpenseForm(addnew: addnewExpense);
              });
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (b) {
                      return ExpenseForm(addnew: addnewExpense);
                    });
              },
              icon: Icon(Icons.add))
        ],
        title: Text('Masroufi'),
      ),
      body: ListView(
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(10),
            height: 100,
            child: Card(
              elevation: 5,
              child: Center(
                  child: Text(
                'EGP ' + calculateTotal().toString(),
                style: TextStyle(fontSize: 30),
              )),
            ),
          ),
          EXListWidget(
              allExpenses: allExpenses.value as List<Expense>,
              deleteExpense: deleteExpense),
        ],
      ),
    );
  }
}
