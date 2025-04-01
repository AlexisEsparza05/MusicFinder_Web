import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Agregar paquete para animaciones

class PayPalPaymentScreen extends StatelessWidget {
  final String precio;

  const PayPalPaymentScreen({Key? key, required this.precio}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pagar con PayPal")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => PaypalCheckoutView(
                sandboxMode: true,
                clientId: 'ATw1GJYt95lRpvj3cj3h44PotTLknbpKfJ5J_2ShCzP511x1qZNfkpbzDzjD4FQngzfbBvQ9LJpb3Dea',
                secretKey: 'EEl_AlhCGM3eDgkUTDo9uNBhB3MFKN7GZJNIfuQv8OxRdm4aFICyiml8qHq4EJmenF8AFDeseXCZs6wu',
                transactions: [
                  {
                    "amount": {
                      "total": precio, 
                      "currency": "MXN",
                      "details": {
                        "subtotal": precio,
                        "shipping": '0',
                        "shipping_discount": 0,
                      }
                    },
                    "description": "Pago por clase de música",
                    "item_list": {
                      "items": [
                        {
                          "name": "Clase de Música",
                          "quantity": 1,
                          "price": precio,
                          "currency": "MXN",
                        }
                      ]
                    }
                  }
                ],
                note: "Gracias por tu compra",
                onSuccess: (Map params) async {
                  print("Pago exitoso: $params");

                  // Mostrar modal animado de éxito
                  _mostrarModalExito(context);

                  Navigator.pop(context);
                },
                onError: (error) {
                  print("Error en el pago: $error");
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al realizar el pago')));
                  Navigator.pop(context);
                },
                onCancel: () {
                  print('Pago cancelado');
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Pago cancelado')));
                  Navigator.pop(context);
                },
              ),
            ));
          },
          child: Text('Pagar con PayPal'),
        ),
      ),
    );
  }

  void _mostrarModalExito(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Evita que se cierre al tocar fuera del modal
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Flecha animada
              Icon(Icons.check_circle, color: Colors.green, size: 80)
                  .animate()
                  .scale(delay: 300.ms, duration: 500.ms)
                  .fadeIn(duration: 500.ms),
              const SizedBox(height: 20),
              // Texto animado
              Text(
                "Pago realizado con éxito",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Aceptar"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
