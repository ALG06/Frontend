# Punto Donativo
## Repositorio Frontend

Este es el repositorio de frontend para el proyecto de *Punto Donativo*.
Debido al uso de tecnologías de Google Maps, este proyecto solo está disponible en las plataformas de iOS y Android, siendo `web` relegado a un segundo plano. 

### Instalación

Por favor checar la documentación en [INSTALLATION.md](./INSTALLATION.md). 

### Ejecución

Utiliza el siguiente comando para *instalar* los paquetes de Flutter 

```bash
flutter pub get
```

Para ejecutar el proyecto, se debe de utilizar el siguiente comando: 

#### iOS
En el caso de testear en iOS, asegurate de tener abierto el simulador de iPhone.
```bash
open -a simulator
```

#### Android 
En el caso de Android, solo es necesario abrir Android Studio una sola vez y abrir el emulador respectivo.  

--- 
Una vez el emulador (iOS / Android) abierto, es solo cuestión de utilizar el siguiente comando:


```bash
flutter run
```

### Testeo Automatizado
Para correr estas pruebas, utiliza el siguiente comando 

```flutter test```
