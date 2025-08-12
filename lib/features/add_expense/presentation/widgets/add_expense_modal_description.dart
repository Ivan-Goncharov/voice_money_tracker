part of 'add_expense_modal.dart';

class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const _DescriptionField({required this.controller, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(
        labelText: 'Description (optional)',
        hintText: 'What did you spend on?',
        prefixIcon: Icon(Icons.description),
      ),
    );
  }
}
