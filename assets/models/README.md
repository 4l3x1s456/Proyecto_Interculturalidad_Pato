# (vacío a propósito)

Los modelos 3D (.glb) ya **no** se empaquetan en la app. Se sirven desde
**Firebase Hosting** (`https://alexgames-app-cultuar.web.app/models/...`) y la
app los descarga una sola vez y los cachea en disco.

- Fuente desplegada: carpeta `public/models/` del proyecto.
- URLs configuradas en `lib/data/culture_seed.dart` (`model3dUrl`).
- Para cambiar/actualizar un modelo: reemplázalo en `public/models/` y corre
  `firebase deploy --only hosting`.

Ver `MODELOS_3D.md` para más detalle.
