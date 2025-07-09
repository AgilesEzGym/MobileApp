import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ezgym/services/api_config.dart';

class SupportScreen extends StatefulWidget {
  final String userEmail;

  const SupportScreen({Key? key, required this.userEmail}) : super(key: key);

  @override
  _SupportScreenState createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController subjectController;
  late TextEditingController messageController;

  String name = '';
  String email = '';
  String subject = '';
  String message = '';
  bool useUserEmail = true;

  File? _image;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    subjectController = TextEditingController();
    messageController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final name = nameController.text;
      final emailToSend = useUserEmail ? widget.userEmail : emailController.text;
      final subject = subjectController.text;
      final message = messageController.text;

      sendSupportRequest(
        name: name,
        email: emailToSend,
        subject: subject,
        message: message,
        image: _image,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Soporte Técnico'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Ingrese su nombre' : null,
              ),
              CheckboxListTile(
                title: Text("Usar correo registrado (${widget.userEmail})"),
                value: useUserEmail,
                onChanged: (value) {
                  setState(() {
                    useUserEmail = value ?? true;
                  });
                },
              ),
              if (!useUserEmail)
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Correo electrónico'),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !useUserEmail,
                  validator: (value) {
                    if (useUserEmail) return null;
                    if (value == null || value.isEmpty) {
                      return 'Ingrese su correo';
                    }
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Correo inválido';
                    }
                    return null;
                  },
                  onSaved: (value) => email = value ?? '',
                ),
              TextFormField(
                controller: subjectController,
                decoration: InputDecoration(labelText: 'Asunto'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Ingrese el asunto' : null,
              ),
              TextFormField(
                controller: messageController,
                decoration: InputDecoration(labelText: 'Mensaje'),
                maxLines: 4,
                validator: (value) =>
                value == null || value.isEmpty ? 'Ingrese el mensaje' : null,
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: Icon(Icons.image),
                label: Text(_image == null
                    ? "Adjuntar imagen (opcional)"
                    : "Cambiar imagen (${_image!.path.split('/').last})"),
                onPressed: _pickImage,
              ),
              if (_image != null) ...[
                const SizedBox(height: 10),
                Image.file(
                  _image!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Enviar solicitud'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendSupportRequest({
    required String name,
    required String email,
    required String subject,
    required String message,
    File? image,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/support');

    final request = http.MultipartRequest('POST', uri);
    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['subject'] = subject;
    request.fields['message'] = message;

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType('image', image.path.split('.').last),
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solicitud enviada correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar solicitud: ${response.body}')),
      );
    }
  }

}
