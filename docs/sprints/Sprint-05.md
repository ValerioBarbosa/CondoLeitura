# Sprint 05 — OCR do medidor

## Entregue
- Reconhecimento automático do valor do medidor via `google_mlkit_text_recognition`, a partir da foto capturada em `PhotoCaptureField`.
- O valor reconhecido só **sugere** — preenche o campo "leitura atual", que continua editável e exige o toque em "Salvar" para confirmar. Nenhuma leitura é criada automaticamente.
- Falha de reconhecimento (ou plataforma sem suporte) nunca bloqueia a digitação manual: o app simplesmente não sugere nada.
- `OcrService` isolado do restante do app via **import condicional** (`ocr_service_stub.dart` para Web, `ocr_service_io.dart` para o resto): o pacote de ML Kit usa `dart:io`, incompatível com Web, então a escolha de qual implementação compilar acontece em tempo de compilação — o código do ML Kit nunca entra na compilação do Web.
- Dentro da variante nativa, `isSupported` verifica `Platform.isAndroid || Platform.isIOS`: no Windows/macOS/Linux desktop (que também têm `dart:io`, mas não têm ML Kit), o OCR fica desabilitado do mesmo jeito que na Web.
- Extração do valor: pega a sequência de dígitos mais longa no texto reconhecido (heurística simples — hidrômetros mostram o valor como o maior bloco de números no visor).

## Importante: o que NÃO foi validado
**O reconhecimento em si nunca rodou num dispositivo real.** Este ambiente de desenvolvimento não tem Android SDK nem macOS/Xcode, então não é possível instalar o app num celular real ou emulador para confirmar que o ML Kit realmente reconhece os dígitos de uma foto de hidrômetro com precisão aceitável. O que foi validado:
- O código compila para Android, iOS e Web sem conflito (Web comprovadamente não carrega nada do ML Kit).
- A lógica de extração do valor (`extractMeterDigits`) tem testes reais e determinísticos.
- O fluxo de UI (sugestão preenchendo o campo, sempre revisável) está implementado e coberto por teste de widget, mas com OCR desabilitado (roda em Linux, sem suporte).

**Antes de considerar OCR pronto de verdade**, é necessário testar num Android ou iPhone real: tirar fotos de hidrômetros de verdade e confirmar que o valor sugerido bate com a leitura. É bem possível que a heurística de extração precise de ajuste (ex.: hidrômetros analógicos com múltiplos mostradores, digitos cortados na foto, reflexo no vidro do medidor).

## Testes necessários
- `flutter analyze`
- `flutter test` (round-trip do parser de dígitos, `OcrService.isSupported` neste ambiente, fluxo de captura sem sugestão quando a plataforma não suporta)
- `flutter build web --release` (confirma que nada do ML Kit vaza para o bundle Web)
- **Pendente**: teste manual num Android e num iPhone reais, fotografando hidrômetros de verdade.
