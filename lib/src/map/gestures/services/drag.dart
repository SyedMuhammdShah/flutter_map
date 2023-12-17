part of 'base_services.dart';

class DragGestureService extends BaseGestureService {
  Offset? _lastLocalFocal;
  Offset? _focalStartLocal;

  bool get _flingEnabled =>
      _options.interactionOptions.enabledGestures.flingAnimation;

  DragGestureService({required super.controller});

  bool get isActive => _lastLocalFocal != null;

  void start(ScaleStartDetails details) {
    controller.stopAnimationRaw();
    _lastLocalFocal = details.localFocalPoint;
    _focalStartLocal = details.localFocalPoint;
    controller.emitMapEvent(
      MapEventMoveStart(
        camera: _camera,
        source: MapEventSource.dragStart,
      ),
    );
  }

  void update(ScaleUpdateDetails details) {
    if (_lastLocalFocal == null) return;

    final offset = _rotateOffset(
      _camera,
      _lastLocalFocal! - details.localFocalPoint,
    );
    final oldCenterPt = _camera.project(_camera.center);
    final newCenterPt = oldCenterPt + offset.toPoint();
    final newCenter = _camera.unproject(newCenterPt);

    controller.moveRaw(
      newCenter,
      _camera.zoom,
      hasGesture: true,
      source: MapEventSource.onDrag,
    );

    _lastLocalFocal = details.localFocalPoint;
  }

  void end(ScaleEndDetails details) {
    controller.emitMapEvent(
      MapEventMoveEnd(
        camera: _camera,
        source: MapEventSource.dragEnd,
      ),
    );
    final lastLocalFocal = _lastLocalFocal!;
    final focalStartLocal = _focalStartLocal!;
    _lastLocalFocal = null;
    _focalStartLocal = null;

    if (!_flingEnabled) return;

    final magnitude = details.velocity.pixelsPerSecond.distance;

    // don't start fling if the magnitude is not high enough
    if (magnitude < 800) {
      controller.emitMapEvent(
        MapEventFlingAnimationNotStarted(
          source: MapEventSource.flingAnimationController,
          camera: _camera,
        ),
      );
      return;
    }

    final direction = details.velocity.pixelsPerSecond / magnitude;

    controller.flingAnimatedRaw(
      velocity: magnitude / 1000.0,
      direction: direction,
      begin: focalStartLocal - lastLocalFocal,
      hasGesture: true,
    );
    controller.emitMapEvent(
      MapEventFlingAnimationStart(
        source: MapEventSource.flingAnimationController,
        camera: _camera,
      ),
    );
  }
}