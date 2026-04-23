import 'package:flutter/material.dart';

class StaffDashboardProvider extends ChangeNotifier {
  int _totalTickets = 12;
  int _newTickets = 5;
  int _onProgressTickets = 4;
  int _doneTickets = 3;

  int get totalTickets => _totalTickets;
  int get newTickets => _newTickets;
  int get onProgressTickets => _onProgressTickets;
  int get doneTickets => _doneTickets;
}