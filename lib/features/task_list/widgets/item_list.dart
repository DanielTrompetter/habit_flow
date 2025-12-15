import 'package:flutter/material.dart';

class ItemList extends StatelessWidget {
  const ItemList({
    super.key,
    required this.items,
    required this.onEdit,
    required this.onDelete,
  });

  final List<String> items;
  final void Function(int index, String newItem) onEdit;
  final void Function(int index) onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(items[index]),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  TextEditingController editController = TextEditingController(
                    text: items[index],
                  );
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Task bearbeiten'),
                        content: TextField(
                          autofocus: true,
                          controller: editController,
                          decoration: const InputDecoration(
                            hintText: "Task bearbeiten",
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Abbrechen'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Speichern'),
                            onPressed: () {
                              onEdit(index, editController.text);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  onDelete(index);
                },
              ),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) =>
          const Divider(thickness: 1, color: Colors.white10),
    );
  }
}
