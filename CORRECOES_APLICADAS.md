# Correções aplicadas

## Falha de compilação Android

O relatório `build/reports/problems/problems-report.html` registrava erros no plugin `camera_android_camerax`, incluindo:

- `package androidx.camera.lifecycle does not exist`;
- `cannot find symbol: ProcessCameraProvider`;
- ausência de `androidx.concurrent.futures.CallbackToFutureAdapter`.

## Ajustes realizados

1. Android Gradle Plugin alterado de `9.0.1` para `8.9.1`.
2. Gradle Wrapper alterado de `9.1.0` para `8.11.1`.
3. Kotlin Gradle Plugin ajustado para `2.1.0`.
4. Plugin `org.jetbrains.kotlin.android` restaurado no módulo `app`.
5. Removidas as flags experimentais `android.newDsl=false` e `android.builtInKotlin=false`.
6. Removida a dependência forçada `androidx.concurrent:concurrent-futures:1.3.0`, deixando o plugin da câmera resolver suas próprias dependências compatíveis.
7. `minSdk` definido em 24 para manter compatibilidade com câmera, geolocalização e ML Kit usados pelo aplicativo.
8. Verificada a existência de todos os arquivos referenciados por imports locais em `lib/`; nenhum import local quebrado foi encontrado.

## Comandos recomendados no Windows

```powershell
flutter clean
Remove-Item -Recurse -Force .dart_tool, build -ErrorAction SilentlyContinue
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

Para APK:

```powershell
flutter build apk --release
```
