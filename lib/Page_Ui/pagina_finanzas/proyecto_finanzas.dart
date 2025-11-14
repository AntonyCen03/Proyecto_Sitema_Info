import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_final/Color/Color.dart';
import 'package:proyecto_final/services/firebase_services.dart';

class ProyectoFinanzasPanel extends StatefulWidget {
  final String docId; // Firestore docId del proyecto en list_proyecto
  final int? idProyecto;
  final String? nombreProyecto;

  const ProyectoFinanzasPanel({
    super.key,
    required this.docId,
    this.idProyecto,
    this.nombreProyecto,
  });

  @override
  State<ProyectoFinanzasPanel> createState() => _ProyectoFinanzasPanelState();
}

class _ProyectoFinanzasPanelState extends State<ProyectoFinanzasPanel> {
  final _formPresupuesto = GlobalKey<FormState>();
  final _formGasto = GlobalKey<FormState>();

  final _presupuestoCtrl = TextEditingController();
  final _motivoCtrl = TextEditingController();
  final _gastoMontoCtrl = TextEditingController();
  final _gastoDescCtrl = TextEditingController();

  bool _loading = false;
  Map<String, dynamic>? _resumen;

  @override
  void initState() {
    super.initState();
    _cargarResumen();
  }

  @override
  void dispose() {
    _presupuestoCtrl.dispose();
    _motivoCtrl.dispose();
    _gastoMontoCtrl.dispose();
    _gastoDescCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarResumen() async {
    setState(() => _loading = true);
    try {
      final r = await getResumenFinancieroProyecto(widget.docId);
      setState(() => _resumen = r);
      // Prefill campo presupuesto si existe
      final p = r['presupuesto'];
      if (p is num) {
        _presupuestoCtrl.text = p.toString();
      }
    } catch (_) {
      // opcional: mostrar error
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double? _parseDouble(String raw) {
    final s = raw.replaceAll(',', '.').trim();
    return double.tryParse(s);
  }

  Future<void> _onSolicitarPresupuesto() async {
    if (!_formPresupuesto.currentState!.validate()) return;
    final monto = _parseDouble(_presupuestoCtrl.text);
    if (monto == null) return;
    setState(() => _loading = true);
    try {
      await solicitarPresupuestoProyecto(
        widget.docId,
        monto,
        motivo: _motivoCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Presupuesto solicitado/actualizado')),
        );
      }
      await _cargarResumen();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al solicitar presupuesto: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onRegistrarGasto() async {
    if (!_formGasto.currentState!.validate()) return;
    final monto = _parseDouble(_gastoMontoCtrl.text);
    if (monto == null) return;
    setState(() => _loading = true);
    try {
      final email = FirebaseAuth.instance.currentUser?.email;
      await registrarGastoProyecto(
        widget.docId,
        monto,
        _gastoDescCtrl.text.trim(),
        usuarioEmail: email,
      );
      _gastoMontoCtrl.clear();
      _gastoDescCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto registrado')),
        );
      }
      await _cargarResumen();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar gasto: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = widget.nombreProyecto ?? 'Proyecto';
    final presupuesto = _resumen?['presupuesto'] as double?;
    final totalGastos = (_resumen?['totalGastos'] as num?)?.toDouble() ?? 0.0;
    final saldo = _resumen?['saldo'] as double?;
    final sobrepasado = _resumen?['sobrepasado'] == true;
    final aprobado = _resumen?['presupuestoAprobado'] == true;
    final fmt = NumberFormat.currency(locale: 'es', symbol: '\$');

    return AbsorbPointer(
      absorbing: _loading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.attach_money, color: primaryOrange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Finanzas • $nombre',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: primaryOrange,
                  ),
                ),
              ),
              if (_loading) const SizedBox(width: 12),
              if (_loading) const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Resumen
          Card(
            elevation: 0,
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _Badge(
                        label: 'Presupuesto',
                        value: presupuesto != null ? fmt.format(presupuesto) : '—',
                      ),
                      _Badge(
                        label: 'Aprobación',
                        value: aprobado ? 'Aprobado' : 'Pendiente',
                        valueColor: aprobado ? Colors.green.shade700 : Colors.orange.shade700,
                      ),
                      _Badge(
                        label: 'Total Gastos',
                        value: fmt.format(totalGastos),
                      ),
                      _Badge(
                        label: 'Saldo',
                        value: saldo != null ? fmt.format(saldo) : '—',
                        valueColor: (saldo == null)
                            ? null
                            : (saldo >= 0 ? Colors.green.shade700 : Colors.red.shade700),
                      ),
                      _Badge(
                        label: 'Estado',
                        value: sobrepasado ? 'Sobrepasado' : 'En límite',
                        valueColor: sobrepasado ? Colors.red.shade700 : Colors.green.shade700,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Solicitar/actualizar presupuesto
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Form(
                key: _formPresupuesto,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Solicitar / Actualizar presupuesto', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _presupuestoCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Monto (ej: 1500.00)',
                              prefixIcon: Icon(Icons.monetization_on),
                            ),
                            validator: (v) {
                              final val = _parseDouble(v ?? '');
                              if (val == null || val <= 0) return 'Monto inválido';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _motivoCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Motivo (opcional)',
                              prefixIcon: Icon(Icons.edit_note),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: _onSolicitarPresupuesto,
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar presupuesto'),
                        style: ElevatedButton.styleFrom(backgroundColor: primaryOrange),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Registrar gasto
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Form(
                key: _formGasto,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Registrar gasto', style: TextStyle(fontWeight: FontWeight.bold)),
                    if (!aprobado) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: const [
                          Icon(Icons.info_outline, color: Colors.orange),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text('El presupuesto aún no está aprobado. No se pueden registrar gastos.'),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _gastoMontoCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Monto (ej: 250.00)',
                              prefixIcon: Icon(Icons.monetization_on_outlined),
                            ),
                            readOnly: !aprobado,
                            validator: (v) {
                              final val = _parseDouble(v ?? '');
                              if (val == null || val <= 0) return 'Monto inválido';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _gastoDescCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Descripción',
                              prefixIcon: Icon(Icons.description_outlined),
                            ),
                            readOnly: !aprobado,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Descripción requerida' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: aprobado ? _onRegistrarGasto : null,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Agregar gasto'),
                        style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Lista de últimos gastos (opcional, útil para ver actividad)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Últimos gastos', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 220,
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('list_proyecto')
                          .doc(widget.docId)
                          .collection('gastos')
                          .orderBy('fecha', descending: true)
                          .limit(20)
                          .snapshots(),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snap.hasData || snap.data!.docs.isEmpty) {
                          return const Center(child: Text('Sin gastos registrados'));
                        }
                        return ListView.separated(
                          itemCount: snap.data!.docs.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final d = snap.data!.docs[i];
                            final m = d.data();
                            final monto = (m['monto'] is num)
                                ? (m['monto'] as num).toDouble()
                                : double.tryParse(m['monto']?.toString() ?? '') ?? 0.0;
                            final desc = (m['descripcion'] ?? '').toString();
                            DateTime? fecha;
                            final f = m['fecha'];
                            if (f is Timestamp) fecha = f.toDate();
                            final createdBy = (m['created_by'] ?? '').toString();
                            return ListTile(
                              dense: true,
                              leading: const Icon(Icons.receipt_long, color: primaryOrange),
                              title: Text(desc),
                              subtitle: Text(
                                '${fecha != null ? DateFormat('dd/MM/yyyy HH:mm').format(fecha) : ''}'
                                '${createdBy.isNotEmpty ? '  •  $createdBy' : ''}',
                              ),
                              trailing: Text(NumberFormat.currency(locale: 'es', symbol: '\$').format(monto)),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _Badge({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.grey.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
