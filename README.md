# Dati sulle elezioni di Camera e Senato del 24/02/2013

Uno script per scaricare e pulire i dati presenti nell'[Archivio storico delle elezioni](http://elezionistorico.interno.gov.it/index.php) del ministero dell'interno.

Cosa fa lo script:

- scarica i dati dell'"**area Italia**", relative a queste elezioni, sino al dettaglio maggiore disponibile (quello dei comuni);
- li "pulisce", corregge e "trasforma";
- crea dei file di insieme.




## Pulizia, correzione e trasformazione

Tutti i CSV di output hanno come *encoding* l'`UTF-8` e come separatore la `,`.

### Due righe vuote nell'intestazione

Tutti i file sono fatti così:

```


Ente;Candidato;Liste/Gruppi;Voti lista;;
AGLIE';PIER LUIGI BERSANI AGLIE';PARTITO DEMOCRATICO;368;;
AGLIE';;SINISTRA ECOLOGIA LIBERTA';38;;
AGLIE';;CENTRO DEMOCRATICO;0;;
```

Sono state rimosse le due righe vuote iniziali.

### Mancanza del separatore nell'intestazione

Nell'intestazione degli `scrutini`, manca il separatore finale a fine riga.

```


Ente;Numero elettori;Numero votanti;Schede bianche;Schede non valide
AGLIE' ;2131;1579;13;91;
AIRASCA ;2920;2354;26;100;
ALA DI STURA ;402;261;5;11;
```

È stato aggiunto il separatore.

### Modifica del separatore di campo

È stato trasformato da `;` a `,`, in quanto molto più "standard" e quindi usabile.

### File prodotti

In output i seguenti file:

- i singoli file, così come presenti nel sito di origine, ma con le operazioni di pulizia e trasformazione descritte sopra;
- il merge di tutti i file singoli in 4 file di insieme:
  - `listeSenato.csv`
  - `listeCamera.csv`
  - `scrutiniCamera.csv`
  - `scrutiniSenato.csv`