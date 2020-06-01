import 'package:flutter/material.dart';
import 'package:fluttercredittransferapp/screens/models/ModelForTransaction.dart';

class RowForHistory extends StatelessWidget {

  final ModelForTransaction transaction;

  RowForHistory({ this.transaction });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 0.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: getImageType(transaction.type),
            ),
            SizedBox(
              width: 10.0,
            ),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    transaction.name,
                    style: TextStyle(
                        fontSize: 18.0
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '${transaction.credit} credits',
                        style: TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                      Text(
                        transaction.dateTime == null ? '' : transaction.dateTime,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget getImageType(String type) {
    if(type == 'to') {
      return Icon(
        Icons.arrow_upward,
        color: Colors.red,
        size: 40.0,
      );
    } else {
      return Icon(
        Icons.arrow_downward,
        color: Colors.green,
        size: 40.0,
      );
    }
  }

}
