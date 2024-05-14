import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/src/gestures/map_interactive_viewer.dart';
import 'package:flutter_map/src/map/inherited_model.dart';
import 'package:logger/logger.dart';

/// An interactive geographical map
///
/// See the online documentation for more information about set-up,
/// configuration, and usage.
@immutable
class FlutterMap extends StatefulWidget {
  /// Creates an interactive geographical map
  ///
  /// See the properties and online documentation for more information about
  /// set-up, configuration, and usage.
  const FlutterMap({
    super.key,
    this.mapController,
    this.options = const MapOptions(),
    required this.children,
  });

  final List<Widget> children;

  final MapOptions options;

  final MapController? mapController;

  @override
  State<FlutterMap> createState() => _FlutterMapStateContainer();
}

class _FlutterMapStateContainer extends State<FlutterMap>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  bool _initialCameraFitApplied = false;

  late MapControllerImpl _mapController;

  bool get _controllerCreatedInternally => widget.mapController == null;

  @override
  void initState() {
    super.initState();
    _setMapController();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.options.onMapReady?.call());

    if (kDebugMode && kIsWeb && !isCanvasKit) {
      Logger(printer: PrettyPrinter(methodCount: 0)).w(
        '\x1B[1m\x1B[3mflutter_map\x1B[0m\nAvoid using HTML rendering on the web '
        'platform. Prefer CanvasKit.\nSee '
        'https://docs.fleaflet.dev/getting-started/installation#web for more '
        'info.',
      );
    }
  }
  @override
  void didUpdateWidget(FlutterMap oldWidget) {
    if (oldWidget.mapController != widget.mapController) {
      _setMapController();
    }
    if (oldWidget.options != widget.options) {
      _mapController.options = widget.options;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (_controllerCreatedInternally) _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final widgets = ClipRect(
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: ColoredBox(color: widget.options.backgroundColor),
          ),

          ...widget.options.applyPointerTranslucencyToLayers
              ? widget.children.map((child) => TranslucentPointer(child: child))
              : widget.children,
        ],
      ),
    );

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          _updateAndEmitSizeIfConstraintsChanged(constraints);

          return MapInteractiveViewer(
            controller: _mapController,
            builder: (context, options, camera) {
              return MapInheritedModel(
                controller: _mapController,
                options: options,
                camera: camera,
                child: widgets,
              );
            },
          );
        },
      ),
    );
  }

  void _applyInitialCameraFit(BoxConstraints constraints) {


    if (!_initialCameraFitApplied &&
        widget.options.initialCameraFit != null &&
        _parentConstraintsAreSet(context, constraints)) {
      _initialCameraFitApplied = true;

      _mapController.fitCamera(widget.options.initialCameraFit!);
    }
  }

  void _updateAndEmitSizeIfConstraintsChanged(BoxConstraints constraints) {
    final nonRotatedSize = Point<double>(
      constraints.maxWidth,
      constraints.maxHeight,
    );
    final oldCamera = _mapController.camera;
    if (_mapController.setNonRotatedSizeWithoutEmittingEvent(nonRotatedSize)) {
      final newMapCamera = _mapController.camera;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.nonRotatedSizeChange(
            MapEventSource.nonRotatedSizeChange,
            oldCamera,
            newMapCamera,
          );

          _applyInitialCameraFit(constraints);
        }
      });
    }
  }
  bool _parentConstraintsAreSet(
          BuildContext context, BoxConstraints constraints) =>
      constraints.maxWidth != 0 || MediaQuery.sizeOf(context) != Size.zero;

  @override
  bool get wantKeepAlive => widget.options.keepAlive;

  void _setMapController() {
    if (_controllerCreatedInternally) {
      _mapController = MapControllerImpl(options: widget.options, vsync: this);
    } else {
      _mapController = widget.mapController! as MapControllerImpl;
      _mapController.vsync = this;
      _mapController.options = widget.options;
    }
  }
}
