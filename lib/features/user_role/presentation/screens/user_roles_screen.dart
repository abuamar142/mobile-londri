import 'package:flutter/material.dart';

import '../../domain/entities/profile.dart';
import '../widgets/widget_activate_user.dart';
import '../widgets/widget_deactivate_user.dart';

class UserRolesScreen extends StatefulWidget {
  const UserRolesScreen({super.key, required this.profiles});

  final List<Profile> profiles;

  @override
  State<UserRolesScreen> createState() => _UserRolesScreenState();
}

class _UserRolesScreenState extends State<UserRolesScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.profiles.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(widget.profiles[index].name),
          subtitle: Text(widget.profiles[index].email),
          trailing: IconButton(
            icon: Icon(
              widget.profiles[index].role == 'user'
                  ? Icons.check_circle
                  : Icons.remove_circle,
              color: widget.profiles[index].role == 'user'
                  ? Colors.green
                  : Colors.red,
            ),
            onPressed: () {
              if (widget.profiles[index].role == 'user') {
                deactivateUser(
                  context: context,
                  profile: widget.profiles[index],
                  index: index,
                );
              } else {
                activateUser(
                  context: context,
                  profile: widget.profiles[index],
                  index: index,
                );
              }
            },
          ),
        );
      },
    );
  }
}

