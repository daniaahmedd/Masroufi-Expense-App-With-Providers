import 'package:flutter/material.dart';
import 'ExlistWidget.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:io';
import 'NewExWidget.dart';
import 'expense.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'expenseProvider.dart' as provider;
import 'package:provider/provider.dart';

import 'expenseProvider.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (ctx) => expenseProvider(),
        child: MaterialApp(
          title: 'Masroufi',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: mainPage(),
        )   //mainPageHook(),
    );
  }
}

class mainPage extends StatefulWidget {
  const mainPage({super.key});

  @override
  State<mainPage> createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {
  final List<expense> allExpenses = [];
  final expenseURL = Uri.parse('https://masroufidb-default-rtdb.firebaseio.com/expensesTable.json');

  @override
  void initState() {  
    final provider = Provider.of<expenseProvider>(context, listen: false);
    provider.fetchExpensesFromServer();
    super.initState();
  }

  double calculateTotal(List<expense> inputExpenses) {
    double total = 0;
    //print('inside calulate total expenseslist => ${inputExpenses}');
    inputExpenses.forEach((e) {
      //print('inside calculate total amount => ${e.amount}');
      total += e.amount;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<expenseProvider>(context, listen: true);
    final allExpenses=provider.getAllExpenses;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (b) {
                return ExpenseForm(addnew: provider.addnewExpense);
              }
          );
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
                      return ExpenseForm(addnew: provider.addnewExpense);
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
                'EGP ' + calculateTotal(allExpenses).toString(),
                style: TextStyle(fontSize: 30),
              )),
            ),
          ),
          EXListWidget(allExpenses: allExpenses, deleteExpense: provider.deleteExpense),
        ],
      ),
    );
  }
}
