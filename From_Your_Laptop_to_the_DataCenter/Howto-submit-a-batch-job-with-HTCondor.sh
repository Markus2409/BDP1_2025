================================================================================
SPIEGAZIONE DEI COMANDI HTCONDOR (DA CODICE DEL PROFESSORE)
================================================================================

--- PREPARAZIONE AMBIENTE ---

1. cp -r /data2/BDP1/condor/ .
   Copia ricorsivamente la cartella 'condor' (contenente gli esempi del corso) 
   dalla directory condivisa '/data2/BDP1/' alla directory corrente del tuo utente 
   (indicata dal punto '.').

2. cd condor
   Entra nella directory appena copiata per lavorare con i file degli esempi.


--- PRIMO ESEMPIO (Ispezione file e sottomissione) ---

3. cat myexec.sh
   Visualizza il contenuto dello script di esecuzione 'myexec.sh'. Questo è 
   probabilmente lo script che verrà eseguito dal job Condor.

4. cat world.txt
   Visualizza il contenuto del file 'world.txt', presumibilmente un file di input 
   o di dati usato dall'esempio.

5. vim first_batch.job
   Apre con l'editor 'vim' il file di descrizione del job 'first_batch.job'. 
   Questo file è fondamentale in Condor perché dice al sistema cosa eseguire, 
   quali sono i file di input/output, le richieste di risorse (CPU, RAM), ecc.

6. condor_status
   Mostra lo stato del cluster HTCondor. Elenca tutte le macchine (nodi) disponibili, 
   quante sono occupate, quante libere e le loro caratteristiche. Serve per 
   verificare se il cluster è attivo e ha risorse disponibili.

7. condor_submit first_batch.job
   Sottomette il job al sistema di batch utilizzando il file di descrizione 
   specificato ('first_batch.job'). Condor prende in carico il lavoro e lo 
   mette in coda.

--- CONTROLLO STATO DEL JOB ---

8. condor_q
   Mostra la coda dei job sottomessi dall'utente corrente che sono ancora attivi 
   (in attesa o in esecuzione).

9. condor_q -better-analyze
   Fornisce un'analisi dettagliata del perché i job in coda non stanno ancora 
   girando (utile per il debugging se un job rimane in stato "Idle" per molto tempo).

10. condor_q -better-analyze <jobID>
    Come sopra, ma specifico per un singolo job identificato dal suo ID (<jobID>).

11. condor_history <jobID>
    Mostra la storia e i dettagli di un job che è già terminato (e quindi non appare 
    più in 'condor_q'). Utile per vedere statistiche post-esecuzione o codici di 
    errore.

--- ISPEZIONE OUTPUT ---

12. cat file1out
    cat file2out
    Visualizza il contenuto dei file di output generati dal job (i nomi dipendono 
    da cosa è scritto nel job file).

13. less condor.out
    less condor.log
    less condor.error
    Visualizza i file di log generati da Condor per il job:
    - condor.out: Standard Output (stdout) del programma eseguito.
    - condor.error: Standard Error (stderr) del programma (utile per vedere errori di runtime).
    - condor.log: Log degli eventi di Condor (quando il job è stato sottomesso, quando è partito, quando è finito).


--- ESEMPIO "HG" CON BWA (Allineamento Genomico) ---

14. cd hg
    Cambia directory entrando nella sottocartella 'hg' (Human Genome example).

15. vim align.py
    Apre lo script Python 'align.py' che presumibilmente esegue l'allineamento 
    usando BWA.

16. vim bwa_batch.job
    Apre il file di sottomissione Condor specifico per questo esempio di allineamento.

17. less condor.error
    less condor.log
    less condor.out
    Visualizza i log e gli output relativi al job di allineamento BWA una volta 
    terminato.

18. cat md5.txt
    Visualizza il contenuto del file 'md5.txt', che probabilmente contiene i checksum 
    per verificare l'integrità dei file generati.
