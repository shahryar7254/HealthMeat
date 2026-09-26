{{flutter_js}}
{{flutter_build_config}}

// Offline: CanvasKit CDN ki jagah local files use karo
_flutter.loader.load({
  config: {
    canvasKitBaseUrl: '/canvaskit/',
  },
});
