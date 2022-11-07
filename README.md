# Data analytics - The Presidential Election of Brazil - 2022
`[PT-br]`

Após as eleições presidenciais 2022 do Brasil existiram algumas denúncias de que o resultado das eleições pode ter sido afetado por anomalias detectadas em versões antigas das urnas eletrônicas.

As denúncias foram inicialmente publicadas por Fernando Cerimedo e seus relatórios estão disponíveis em /docs e também em https://brazilwasstolen.com.

O objetivo desse projeto é fazer o download dos resultados de votação diretamento do TSE, enriquecer os dados com informações que estão espalhadas em outros arquivos do TSE e disponibilizar o arquivo `.csv` final para que qualquer um possa fazer a análise nos dados.

`[EN-us]`

After the presidential elections of Brazil in 2022, some complaints were filed arguing that the election results could be affected by some anomalous patterns found in old ballot models.

The reports were originally published by Fernando Cerimedo. His reports are available in `/docs` and at https://brazilwasstolen.com.

The purpose of this project is to download the election results from TSE API, enrich the files by adding information found in other TSE files, and make the final `.csv` file available for everyone to build their own data analysis.

## Build 
```
bundle install
```
## Run
```
rake run
```
## Requirements
- Ruby
## How it works
This project does the followin steps:
- downloads the election results csv files from [https://dadosabertos.tse.jus.br](https://dadosabertos.tse.jus.br/dataset/resultados-2022-correspondencias-esperadas-e-efetivadas-2-turno);
- downloads the logs of each of the ballots and looks for the ballot model in the logs (check out the TSE API below);
- generates one `.csv` file per State of Brazil, normalizing the data and adding a column for the ballot model.
- the file `csv` files will be generated at `~/elections_data/processed`

## TSE API
### Parameters:
- `cod_turno`:
    - 1 turno 2022: `406`
    - 2 turno 2022: `407`

### API
- lista de seções por estado:
    - API: `https://resultados.tse.jus.br/oficial/ele2022/arquivo-urna/{cod_turno}/config/{estado}/{estado}-p000{cod_turno}-cs.json`
    - Alagoas: https://resultados.tse.jus.br/oficial/ele2022/arquivo-urna/407/config/al/al-p000407-cs.json
    - São Paulo: https://resultados.tse.jus.br/oficial/ele2022/arquivo-urna/407/config/sp/sp-p000407-cs.json

- get hash por urna:
    - API: `https://resultados.tse.jus.br/oficial/ele2022/arquivo-urna/{cod_turno}/dados/{estado}/{cod_municipio}/{zona}/{seção}/p000{cod_turno}-{estado}-m{cod_municipio}-z{zona}-s{seção}-aux.json`
    - sample: https://resultados.tse.jus.br/oficial/ele2022/arquivo-urna/407/dados/sp/62910/0033/0003/p000407-sp-m62910-z0033-s0003-aux.json
              https://resultados.tse.jus.br/oficial/ele2022/arquivo-urna/407/dados/rr/3018/1/1/p000407-rr-m3018-z1-s1-aux.json

- Registro Digital de Voto - RDV (por urna):
    - API: `https://resultados.tse.jus.br/oficial/ele2022/arquivo-urna/{cod_turno}/dados/{estado}/{cod_municipio}/{zona}/{seção}/{hash}/o00{cod_turno}-{cod_municipio}{zona}{seção}.rdv`
    - sample: https://resultados.tse.jus.br/oficial/ele2022/arquivo-urna/407/dados/sp/62910/0033/0003/5a31496f37547a4465723739546a34564b444250465458576c724f4c726561642d522d6f545363305758673d/o00407-6291000330003.rdv

- Log da Urna (por urna):
    - API: `https://resultados.tse.jus.br/oficial/ele2022/arquivo-urna/{cod_turno}/dados/{estado}/{cod_municipio}/{zona}/{seção}/{hash}/o00{cod_turno}-{cod_municipio}{zona}{seção}.logjez`
    - sample: https://resultados.tse.jus.br/oficial/ele2022/arquivo-urna/407/dados/sp/62910/0033/0003/5a31496f37547a4465723739546a34564b444250465458576c724f4c726561642d522d6f545363305758673d/o00407-6291000330003.logjez

- CSVs totalizados por seção (por estado):
    - API: `https://cdn.tse.jus.br/estatistica/sead/eleicoes/eleicoes2022/buweb/bweb_2t_{upper(estado)}_311020221535.zip`
    - sample primeiro turno: https://cdn.tse.jus.br/estatistica/sead/eleicoes/eleicoes2022/buweb/bweb_1t_AL_051020221321.zip
    - sample segundo turno: https://cdn.tse.jus.br/estatistica/sead/eleicoes/eleicoes2022/buweb/bweb_2t_AL_311020221535.zip

## License

The project is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).