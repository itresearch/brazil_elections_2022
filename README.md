# API TSE para download dos dados de votação das urnas

## Params:
- `cod_turno`:
    - 1 turno 2022: `406`
    - 2 turno 2022: `407`

## APIs
- lista de seções por estado:
    - Alagoas: https://resultados.tse.jus.br/oficial/ele2022/arquivo-urna/407/config/al/al-p000407-cs.json
    - São Paulo: https://resultados.tse.jus.br/oficial/ele2022/arquivo-urna/407/config/sp/sp-p000407-cs.json
    - API: `https://resultados.tse.jus.br/oficial/ele2022/arquivo-urna/{cod_turno}/config/{estado}/{estado}-p000{cod_turno}-cs.json`

- get hash por urna:
    - sample: https://resultados.tse.jus.br/oficial/ele2022/arquivo-urna/407/dados/sp/62910/0033/0003/p000407-sp-m62910-z0033-s0003-aux.json
    - API: `https://resultados.tse.jus.br/oficial/ele2022/arquivo-urna/{cod_turno}/dados/{estado}/{cod_municipio}/{zona}/{seção}/p000{cod_turno}-{estado}-m{cod_municipio}-z{zona}-s{seção}-aux.json`

- Registro Digital de Voto - RDV (por urna):
    - sample: https://resultados.tse.jus.br/oficial/ele2022/arquivo-urna/407/dados/sp/62910/0033/0003/5a31496f37547a4465723739546a34564b444250465458576c724f4c726561642d522d6f545363305758673d/o00407-6291000330003.rdv
    - API: `https://resultados.tse.jus.br/oficial/ele2022/arquivo-urna/{cod_turno}/dados/{estado}/{cod_municipio}/{zona}/{seção}/{hash}/o00{cod_turno}-{cod_municipio}{zona}{seção}.rdv`

- Log da Urna (por urna):
    - sample: https://resultados.tse.jus.br/oficial/ele2022/arquivo-urna/407/dados/sp/62910/0033/0003/5a31496f37547a4465723739546a34564b444250465458576c724f4c726561642d522d6f545363305758673d/o00407-6291000330003.logjez
    - API: `https://resultados.tse.jus.br/oficial/ele2022/arquivo-urna/{cod_turno}/dados/{estado}/{cod_municipio}/{zona}/{seção}/{hash}/o00{cod_turno}-{cod_municipio}{zona}{seção}.logjez`
