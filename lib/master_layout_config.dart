import 'package:flutter/material.dart';
import 'package:web_admin/views/widgets/portal_master_layout/sidebar.dart';

final sidebarMenuConfigs = [
  SidebarMenuConfig(
    uri: '/dashboard',
    icon: Icons.dashboard,
    title: (context) => 'Dashboard',
  ),
  SidebarMenuConfig(
    uri: '/users',
    icon: Icons.people,
    title: (context) => 'Users',
  ),
  SidebarMenuConfig(
    uri: '/scooters',
    icon: Icons.electric_scooter,
    title: (context) => 'scooters',
  ),
  SidebarMenuConfig(
    uri: '/stations',
    icon: Icons.location_on,
    title: (context) => 'stations',
  ),
  SidebarMenuConfig(
    uri: '/ride',
    icon: Icons.history_outlined,
    title: (context) => 'rides',
  ),
];
