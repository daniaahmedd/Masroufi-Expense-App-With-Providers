import 'dart:io';
import 'package:flutter/material.dart';
import './expense.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class expenseProvider with ChangeNotifier {
  final List<expense> allExpenses = [];
  final expenseURL = Uri.parse('https://masroufidb-default-rtdb.firebaseio.com/expensesTable.json');

    List<expense> get getAllExpenses {
    return allExpenses;
    }
   Future<void> fetchExpensesFromServer() async {
    try {
      var response = await http.get(expenseURL);
      if(json.decode(response.body) == null){
        return;
      }
      var fetchedData = json.decode(response.body) as Map<String, dynamic>;
      print(fetchedData);

      allExpenses.clear();
      fetchedData.forEach((key, value) {
        print(value['expenseDate']);
        allExpenses.add(expense(
          id: key,
          title: value['expenseTitle'],
          amount: value['expenseAmount'],
          date: DateTime.parse(value['expenseDate'])
        ));
      });
      notifyListeners();
    } catch (err) {
      print(err);
    }
  }
  double calculateTotalAmount(data){
    
    double total = 0;
    data.forEach((e) {
      total += e.expenseAmount;
    });
    return total;
  }
  Future<void> addExpensetoDB(String t,double a, DateTime d) {
    return http
    .post(expenseURL, body: json.encode({'expenseTitle':t, 'expenseAmount': a, 'expenseDate': d.toIso8601String()}))
    .then((response) {
    }).catchError((err) {
    print("provider:" + err.toString());
    throw err;
    });
  }
  Future<void> deleteEx(String id_to_delete) async {
    print(id_to_delete);
    var ideaToDeleteURL = Uri.parse(
    'https://masroufidb-default-rtdb.firebaseio.com/expensesTable/$id_to_delete.json');
    try {
     var response=await http.delete(ideaToDeleteURL); // wait for the delete request to be done
     print('hi from response');
     print(response.body);
    } catch (err) {
    print(err);
    }

    }
    void addnewExpense(
      {required String t, required double a, required DateTime d}) {
    
     addExpensetoDB(t, a, d).then((value) => allExpenses.add(
          expense(amount: a, date: d, id: DateTime.now().toString(), title: t)))
      ;
    
    notifyListeners();
    fetchExpensesFromServer();
  }

  void deleteExpense({required String id}) {
      //print('id');
      //print(id);
      deleteEx(id).then((value) {
        //print('hereeeee');
      
        allExpenses.removeWhere((element) {
        // when done, remove it locally.
        return element.id == id;
          });
      notifyListeners();
      //print('allExpenses =>>>> $allExpenses');
    });
  }

}