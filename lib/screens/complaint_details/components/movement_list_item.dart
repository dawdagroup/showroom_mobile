import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../modals/aftersale_detailed_modal.dart';

class MovementListItem extends StatelessWidget {
  final MovementsLine movementLine;
  final VoidCallback onTap;

  const MovementListItem({
    super.key,
    required this.movementLine,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: ListTile(
          title: Text(movementLine.aftersalesMoveTypeDetails),
          subtitle: Text(movementLine.aftersalesCollectionNo.toString()),
          trailing: Text(DateFormat('dd-MM-yyyy').format(DateFormat('yyyy-MM-dd').parse(movementLine.aftersalesDate))),
        ),
      ),
    );
  }
}