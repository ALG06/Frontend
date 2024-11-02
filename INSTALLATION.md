# Instalación

Para instalar este proyecto, asegurate de tener el [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado. 

En primera instancia, es necesario crear un archivo `env` (No es `.env`) y ahí poner las variables de entorno de `MAPS_API_KEY` y `MAPS_API_URL`, ambas obtenidas directamente por el [Kit de Desarrollo de Google Maps](https://developers.google.com/maps/documentation/android-sdk/overview)

## iOS
Para ejecutar este proyecto en iOS, deberás de tener **Cocoapods** instalado. Puedes hacerlo a través de [Brew](https://formulae.brew.sh/formula/cocoapods). Además, asegurate de instalar las [herramientas de desarrollo de iOS / macOS](https://developer.apple.com/macos/). 

Además, en la carpeta de `ios` es necesario crear un archivo `Config.xcconfig` y poner las mismas credenciales que en el archivo `env` previamente creado.


## Android 
Para ejecutar este proyecto en Android, deberás de tener [Android Studio SDK](https://developer.android.com/studio). 

Además, en el archivo local de `local.properties`, deberás de agregar las mismas variables de entorno que hay en el archivo `env`. 