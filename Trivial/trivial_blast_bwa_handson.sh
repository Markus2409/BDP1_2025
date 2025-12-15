================================================================================
SPIEGAZIONE PARTE 1: ACCESSO, TRIVIAL SEARCH E BLAST
================================================================================

--- 1. ACCESSO AL SERVER (Login) ---

1. ssh -i <YUOR_AWS_KEY> ec2-user@<AWS_server_Public_IP>
   Si connette via SSH al server remoto su AWS.
   - '-i <KEY>': Specifica la chiave privata (.pem) per l'autenticazione.
   - 'ec2-user': È l'utente di default per le macchine Amazon Linux/RHEL su AWS.

2. sudo su -
   Passa all'utente 'root' (amministratore) per avere i permessi necessari per 
   installare software ed eseguire comandi di sistema.


--- 2. TRIVIAL SEARCH (Ricerca "Brute Force") ---

Questo blocco dimostra un approccio inefficiente alla ricerca di stringhe, utile 
come confronto (baseline) per vedere quanto sono veloci i tool specializzati.

3. cp /data2/BDP1/trivial/trivial_str_search.py .
   cp /data2/BDP1/trivial/shining.txt.gz .
   Copia lo script Python di ricerca e il file di testo compresso (shining.txt.gz) 
   dalla directory condivisa '/data2' alla directory corrente.

4. gunzip -l shining.txt.gz
   Mostra le informazioni sul file compresso (dimensione originale, compression 
   ratio) senza decomprimerlo.

5. gunzip shining.txt.gz
   Decomprime il file, ottenendo 'shining.txt'.

6. md5sum shining.txt
   Calcola l'hash MD5 del file appena decompresso. Serve a verificare l'integrità 
   dei dati (che il file non sia corrotto).

7. cat /data2/BDP1/trivial/md5_shining.txt
   Visualizza il checksum corretto (golden copy) per confrontarlo con quello 
   appena calcolato. Devono essere identici.

8. vim trivial_str_search.py
   Apre lo script Python per ispezionarne il codice (probabilmente un algoritmo 
   brute force che cerca una stringa carattere per carattere).

9. ./trivial_str_search.py
   Esegue lo script. Nota quanto tempo impiega: questo è il riferimento per 
   l'approccio "lento".


--- 3. BLAST (Basic Local Alignment Search Tool) ---

BLAST è un tool euristico standard per l'allineamento di sequenze biologiche.

10. ll /data2/BDP1/hg19/ncbi-blast-2.16.0+-1.x86_64.rpm
    Verifica che il pacchetto di installazione RPM di BLAST sia presente.

11. yum localinstall /data2/BDP1/hg19/ncbi-blast-2.16.0+-1.x86_64.rpm
    Installa BLAST usando il gestore pacchetti yum.

12. (Nota su makeblastdb)
    Lo script indica che l'indice del genoma (necessario a BLAST per cercare 
    velocemente) è GIÀ stato creato. Non bisogna rieseguire 'makeblastdb' perché 
    richiederebbe molto tempo su un genoma grande come HG19 (Human Genome).

13. ls -l /data2/BDP1/hg19/
    Controlla la directory dove risiede l'indice già pronto.

14. cp /data2/BDP1/hg19/myread.fa .
    Copia il file di query ('myread.fa', che contiene la sequenza di DNA da cercare) 
    nella directory di lavoro.

15. time blastn -db /.../entire_hg19BLAST -query myread.fa -out blast_myread.out
    Esegue la ricerca vera e propria.
    - 'time': Misura quanto ci mette il comando.
    - 'blastn': Usa l'algoritmo nucleotide-to-nucleotide.
    - '-db': Specifica il percorso del database indicizzato.
    - '-query': Il file con la sequenza da cercare.
    - '-out': Dove salvare i risultati.

    NOTA SULLE PRESTAZIONI: La prima volta che lo lanci sarà lento perché deve 
    leggere l'indice dal disco.

16. less blast_myread.out
    Visualizza i risultati dell'allineamento.

17. sync; echo 1 > /proc/sys/vm/drop_caches
    (Comando suggerito nei commenti). Svuota la cache della RAM (Page Cache). 
    Se esegui BLAST due volte di fila senza questo comando, la seconda volta sarà 
    velocissimo perché i dati del genoma sono già in RAM. Eseguendo questo comando, 
    forzi il sistema a rileggere dal disco, simulando la "prima esecuzione" per 
    un confronto onesto dei tempi di I/O.

================================================================================
SPIEGAZIONE PARTE 2: COMPILAZIONE ED ESECUZIONE BWA
================================================================================

--- 1. PREPARAZIONE E COMPILAZIONE (Install from Source) ---

A differenza di BLAST (installato via RPM), qui simuliamo lo scenario tipico 
di un ambiente scientifico/HPC dove il software va compilato dal codice sorgente.

1. cp /data2/BDP1/hg19/bwa-0.7.15.tar .
   Copia l'archivio del codice sorgente di BWA nella directory corrente.

2. yum install gcc gcc-c++ zlib zlib-devel
   Installa i compilatori (C e C++) e le librerie di compressione (zlib) necessarie 
   per trasformare il codice sorgente in un eseguibile.

3. tar -xvf bwa-0.7.15.tar
   Scompatta l'archivio.

4. cd bwa-0.7.15/
   Entra nella cartella del sorgente.

--- 5. IL PATCHING DEL CODICE (Passaggio Critico) ---
   Lo script segnala un errore noto nel codice sorgente di questa versione vecchia 
   di BWA con i compilatori moderni.
   Bisogna modificare manualmente un file (probabilmente 'rle.c' o un header):
   - Trovare la riga 33: "const uint8_t rle_auxtab[8];"
   - Modificarla in: "extern const uint8_t rle_auxtab[8];"
   Senza questa modifica, il comando successivo ('make') fallirà con errori di linker.

6. make
   Compila il codice. Se va a buon fine, crea il file binario eseguibile 'bwa'.

7. export PATH=$PATH:/your_path/bwa-0.7.15/
   Aggiunge la cartella corrente al PATH di sistema, così da poter lanciare 'bwa' 
   da qualsiasi posizione.
   NOTA: Sostituisci '/your_path/' con il percorso reale (es. /root/bwa-0.7.15/).


--- 2. ESECUZIONE DELL'ALLINEAMENTO (BWA Alignment) ---

BWA è molto più efficiente di BLAST per allineare intere sequenze genomiche, ma 
richiede due passaggi distinti.

8. (Nota sull'Indice)
   Come per BLAST, l'indice del genoma (hg19bwaidx) è GIÀ pronto in /data2. 
   Crearlo da zero richiederebbe ore.

9. bwa aln -t 1 /.../hg19bwaidx myread.fa > myread.sai
   Primo passo (Algoritmo BWA-Backtrack):
   - '-t 1': Usa 1 thread (CPU core).
   - Input: L'indice del genoma e le nostre letture (myread.fa).
   - Output: Un file '.sai' (Suffix Array Index).
   IMPORTANTE: Il file .sai è binario e NON leggibile dall'uomo. Contiene le 
   posizioni grezze degli allineamenti.

10. bwa samse -n 10 /.../hg19bwaidx myread.sai myread.fa > myread.sam
    Secondo passo (Conversione in SAM):
    - 'samse': Genera allineamenti per "Single End" reads (letture singole).
    - Input: Prende il file .sai generato prima e il file .fa originale.
    - Output: Un file '.sam' (Sequence Alignment/Map).
    Questo file è leggibile (testo ASCII) e contiene l'allineamento finale standard.

11. less myread.sam
    Visualizza il risultato finale. Qui vedrai dove la sequenza si colloca nel 
    genoma umano.

12. ls -l /data2/BDP1/hg19/reads/Patients
    Mostra la directory contenente i dati dei pazienti reali (molto grandi), che 
    saranno oggetto delle sfide successive (Grid/Cloud computing).
