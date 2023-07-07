import 'dart:convert';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';



class UsageScreen extends StatefulWidget {
  final String apiKey;

  UsageScreen({required this.apiKey});
  @override
  _UsageScreenState createState() => _UsageScreenState();
}

class _UsageScreenState extends State<UsageScreen> {
  late DateTime startDate;
  late DateTime endDate;
  List<charts.Series<MapEntry<DateTime, double>, DateTime>> chartData = [];

  @override
  void initState() {
    super.initState();
    startDate = DateTime.now().subtract(const Duration(days: 5));
    endDate = DateTime.now();
    updateChartData();
  }


  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? startDate : endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );

    if (selectedDate != null) {
      setState(() {
        if (isStartDate) {
          startDate = selectedDate;
        } else {
          endDate = selectedDate;
        }
      });
    }
    updateChartData();
  }

  updateChartData() {
    fetchChartData().then((data) {
      setState(() {
        chartData = data;
      });
    }).catchError((error) {
      // Handle error
      print('Error: $error');
    });
  }
  Future<List<charts.Series<MapEntry<DateTime, double>, DateTime>>> fetchChartData() async {
    final apiUrl = Uri.parse(
        'https://api.openai.com/dashboard/billing/usage?start_date=${DateFormat('yyyy-MM-dd').format(startDate)}&end_date=${DateFormat('yyyy-MM-dd').format(endDate)}');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.apiKey}',
    };

    final response = await http.get(apiUrl, headers: headers);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final dailyCosts = jsonData['daily_costs'];

      final data = dailyCosts.map<MapEntry<DateTime, double>>((dailyCost) {
        final timestamp = dailyCost['timestamp'].toInt();
        final lineItems = dailyCost['line_items'];

        double totalCost = 0.0;

        for (var item in lineItems) {
          totalCost += item['cost'];
        }

        final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

        return MapEntry(dateTime, totalCost);
      }).toList();

      final series = [
        charts.Series<MapEntry<DateTime, double>, DateTime>(
          id: 'Cost',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (entry, _) => entry.key,
          measureFn: (entry, _) => entry.value,
          data: data,
        ),
      ];

      return series;
    } else {
      throw Exception('Failed to fetch chart data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usage Screen'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => _selectDate(context, true),
            child: const Text('Select Start Date'),
          ),
          ElevatedButton(
            onPressed: () => _selectDate(context, false),
            child: const Text('Select End Date'),
          ),
          Expanded(
            child: charts.TimeSeriesChart(
              chartData,
              animate: true,
              dateTimeFactory: const charts.LocalDateTimeFactory(),
            ),
          ),
        ],
      ),
    );
  }
}
