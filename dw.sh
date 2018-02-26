#!/bin/bash

### requisiti ###
# - csvkit https://csvkit.readthedocs.io
# - pup https://github.com/EricChiang/pup
### requisiti ###

# download area Italia elezioni Camera 2013-02-24
curl "http://elezionistorico.interno.gov.it/index.php?tpel=C&dtel=24/02/2013&tpa=I&tpe=A&lev0=0&levsut0=0&es0=S&ms=S" |
	pup 'div#collapseFour div.sezione  a json{}' | in2csv -I -f json | sed 's/\&amp;/\&/g' | csvformat -T | sed '1d' |
	while IFS=$'\t' read -r urlCircoscrizione tag text title; do
		# download circoscrizioni
		echo "circoscrizione: $text"
		curl "http://elezionistorico.interno.gov.it""$urlCircoscrizione" | pup 'div#collapseFive div.sezione  a json{}' | in2csv -I -f json | sed 's/\&amp;/\&/g' | csvformat -T | sed '1d' |
			while IFS=$'\t' read -r urlProvincia tag text title; do
				echo "provincia: $text"
				# download provincia
				curl "http://elezionistorico.interno.gov.it""$urlProvincia" |
					pup 'div.panel:nth-child(6) div:parent-of(a:parent-of(i[title="Scrutini"])) a:not(:first-child) attr{href}' |
					while read line; do
						URI=$(echo $line | sed 's/\&amp;/\&/g')
                        # download file
						curl -JLO http://elezionistorico.interno.gov.it/"$URI"
					done
			done
	done

# download area Italia elezioni Senato 2013-02-24
curl "http://elezionistorico.interno.gov.it/index.php?tpel=S&dtel=24/02/2013&tpa=I&tpe=A&lev0=0&levsut0=0&es0=S&ms=S" |
	pup 'div#collapseFour div.sezione  a json{}' | in2csv -I -f json | sed 's/\&amp;/\&/g' | csvformat -T | sed '1d' |
	while IFS=$'\t' read -r urlCircoscrizione tag text title; do
		# download circoscrizioni
		echo "circoscrizione: $text"
		curl "http://elezionistorico.interno.gov.it""$urlCircoscrizione" | pup 'div#collapseFive div.sezione  a json{}' | in2csv -I -f json | sed 's/\&amp;/\&/g' | csvformat -T | sed '1d' |
			while IFS=$'\t' read -r urlProvincia tag text title; do
				echo "provincia: $text"
				# download provincia
				curl "http://elezionistorico.interno.gov.it""$urlProvincia" |
					pup 'div.panel:nth-child(6) div:parent-of(a:parent-of(i[title="Scrutini"])) a:not(:first-child) attr{href}' |
					while read line; do
						URI=$(echo $line | sed 's/\&amp;/\&/g')
                        # download file
						curl -JLO http://elezionistorico.interno.gov.it/"$URI"
					done
			done
	done

# creo cartella per csv
mkdir -p ./csv

# correggo un errore nei file SCRUTINI
for i in SCRUTINI*.csv; do sed -i -r '3 s/non valide$/non valide;/' "$i"; done

# rimuovo le prime due righe e imposto come separatore la ";", creando dei nuovi file di output
for i in *.csv; do csvclean "$i" --skip-lines 2 -d ";"; done

mv ./*_out.csv ./csv

cd ./csv

# creo l'anagrafica
for i in LISTE-S*.csv; do echo "$i" | sed -r 's/^(.*?-.*?-.*?-.*?-)(.*?)-(.*?)-Comune.*$/\2,\3/g'; done >./00_anagraficaSenato.csv
sed -i '1 i\circoscrizione,provincia' ./00_anagraficaSenato.csv
for i in LISTE-C*.csv; do echo "$i" | sed -r 's/^(.*?-.*?-.*?-.*?-)(.*?)-(.*?)-Comune.*$/\2,\3/g'; done >./00_anagraficaCamera.csv
sed -i '1 i\circoscrizione,provincia' ./00_anagraficaCamera.csv

# faccio il merge dei file di liste e scrutini
csvstack LISTE-S*.csv >./listeSenato.csv
csvstack SCRUTINI-S*.csv >./scrutiniSenato.csv
csvstack LISTE-C*.csv >./listeCamera.csv
csvstack SCRUTINI-C*.csv >./scrutiniCamera.csv

rm ../*.csv
