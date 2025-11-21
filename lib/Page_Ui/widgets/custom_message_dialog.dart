import 'package:flutter/material.dart';

void showMessageDialog(BuildContext context, String message,
    {bool isError = false}) {
  showDialog(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isError ? Icons.cancel : Icons.check_circle,
              color: isError ? Colors.red : Colors.green,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              isError ? '¡Atención!' : '¡Éxito!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isError ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isError ? Colors.red : Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Aceptar',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    ),
  );
}
