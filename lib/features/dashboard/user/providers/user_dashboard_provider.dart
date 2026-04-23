import 'package:flutter/material.dart';

class UserDashboardProvider extends ChangeNotifier {
  int _openTickets = 2;
  int _inProgressTickets = 1;
  int _closedTickets = 0;

  int get openTickets => _openTickets;
  int get inProgressTickets => _inProgressTickets;
  int get closedTickets => _closedTickets;
}