import 'package:example_app/model/todo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CreateTodoWidget extends StatefulWidget {
  final Todo? todo;
  final ValueChanged<String> onSubmit;
  const CreateTodoWidget({
    Key? key,
    this.todo,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<CreateTodoWidget> createState() => _CreateTodoWidgetState();
}

class _CreateTodoWidgetState extends State<CreateTodoWidget> {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller.text = widget.todo?.title ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.todo != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Todo' : 'Add Todo'),
      content: Form(
        key: formKey,
        child: TextFormField(
          autofocus: true,
          controller: controller,
          decoration: const InputDecoration(hintText: 'Title'),
          validator: (value) =>
              value != null && value.isEmpty ? 'Title is required' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              widget.onSubmit(controller.text);
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
