# Dados

## Torre/Bloco
- id
- condominiumId
- name
- code (opcional)
- notes (opcional)
- isActive
- createdAt
- updatedAt

Quantidade de andares e de unidades não pertence à torre. Esses indicadores serão calculados a partir das unidades cadastradas.

## Unidade
- id
- towerId
- number
- floor (opcional)
- code (opcional)
- notes (opcional)
- isActive
- createdAt
- updatedAt

Quantidade de hidrômetros não pertence à unidade. Esse indicador é calculado a partir dos medidores cadastrados.

## Medidor (Hidrômetro)
- id
- unitId
- type (Água ou Gás)
- serialNumber (opcional)
- notes (opcional)
- isActive
- createdAt
- updatedAt

Uma unidade pode ter mais de um medidor (tipicamente um de água e um de gás).
