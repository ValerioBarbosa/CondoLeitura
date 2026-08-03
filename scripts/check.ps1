$ErrorActionPreference = "Stop"

Write-Host "[1/4] Instalando dependências..." -ForegroundColor Cyan
flutter pub get

Write-Host "[2/4] Verificando formatação..." -ForegroundColor Cyan
dart format --output=none --set-exit-if-changed lib test

Write-Host "[3/4] Executando análise..." -ForegroundColor Cyan
flutter analyze

Write-Host "[4/4] Executando testes..." -ForegroundColor Cyan
flutter test

Write-Host "Validação concluída com sucesso." -ForegroundColor Green
