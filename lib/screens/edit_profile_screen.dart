import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../services/userApi.dart';

class EditProfileScreen extends StatefulWidget {
  final String id;
  final profileModel perfil;

  const EditProfileScreen({
    Key? key,
    required this.id,
    required this.perfil,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController surnameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.perfil.name);
    surnameController = TextEditingController(text: widget.perfil.surname);
    emailController = TextEditingController(text: widget.perfil.email);
    phoneController = TextEditingController(text: widget.perfil.phone);
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  bool validateInputs() {
    if (nameController.text.trim().isEmpty ||
        surnameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todos los campos son obligatorios")),
      );
      return false;
    }
    return true;
  }

  Future<bool?> showConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar cambios'),
          content:
              const Text('¿Estás seguro de que quieres guardar los cambios?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              child: const Text('Guardar'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveChanges() async {
    if (!validateInputs()) return;

    final confirm = await showConfirmDialog(context);
    if (confirm != true) return;

    setState(() {
      isSaving = true;
    });

    final updatedProfile = profileModel(
      name: nameController.text.trim(),
      surname: surnameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      photo: widget.perfil.photo,
    );

    try {
      final success = await UserApi.updateProfile(widget.id, updatedProfile);
      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al guardar los cambios")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: surnameController,
              decoration: const InputDecoration(labelText: 'Apellido'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Correo'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSaving ? null : saveChanges,
              child: isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Guardar cambios"),
            ),
          ],
        ),
      ),
    );
  }
}
