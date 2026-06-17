# Modelos 3D (.glb) locales

Coloca aqui los modelos 3D de cada cultura, con **exactamente** estos nombres
(la app los referencia por `lib/data/culture_seed.dart`):

| Archivo | Cultura |
|---------|---------|
| `otavalo.glb`  | Kichwa Otavalo |
| `saraguro.glb` | Saraguro |
| `shuar.glb`    | Shuar |
| `tsachila.glb` | Tsachila |
| `waorani.glb`  | Waorani |

Solo formato **`.glb`** (glTF binario).

## IMPORTANTE: tamano y rendimiento
Cada modelo bundleado se suma al tamano del APK. 5 modelos de 100 MB = APK de
~500 MB (no instalable de forma practica). **Comprime los modelos** antes de
ponerlos aqui; ver `MODELOS_3D.md` para los comandos. Objetivo recomendado:
**< 15 MB** por modelo (RNF-007 del ERS).
