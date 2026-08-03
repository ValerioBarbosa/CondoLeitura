# CondoLeitura — MVP funcional

Esta revisão transforma a tela vazia em um MVP navegável e persistente.

## Incluído
- painel responsivo para web, Windows e celular;
- cadastro e exclusão de condomínios;
- registro de leituras de água e gás;
- validação da leitura atual;
- histórico com consumo calculado;
- resumo de relatórios;
- configurações básicas;
- persistência local com SharedPreferences;
- API atual do share_plus mantida.

## Teste
```powershell
flutter pub get
flutter analyze
flutter run -d chrome
```

## Limites desta entrega
OCR real por câmera, sincronização com servidor e exportação final de arquivos dependem de configuração específica da plataforma e backend. Os serviços existentes foram preservados para a próxima integração.
