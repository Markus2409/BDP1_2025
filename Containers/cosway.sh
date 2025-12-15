================================================================================
GUIDA: DOCKER INTERATTIVO, DOCKERFILE E SINGULARITY SU HPC
================================================================================

Questa sezione mostra due metodi per creare un'immagine personalizzata (metodo 
manuale "commit" vs "Dockerfile") e come portarla su un supercomputer (Leonardo) 
usando Singularity.

--- 1. METODO MANUALE (Interactive Run + Commit) ---

1. docker run -i -t ubuntu /bin/bash
   Avvia un container Ubuntu base in modalità interattiva.

2. Comandi dentro il container:
   - apt-get update: Aggiorna i repository.
   - apt-get install fortunes cowsay lolcat: Installa tre pacchetti:
     * fortune: Genera frasi casuali.
     * cowsay: Disegna una mucca ASCII che "dice" una frase.
     * lolcat: Colora l'output con colori arcobaleno.
   - export PATH=/usr/games/:$PATH: Aggiunge la cartella dei giochi al PATH 
     (altrimenti la shell non trova i comandi appena installati).
   - fortune | cowsay | lolcat: Test della pipe. L'output di fortune diventa 
     l'input di cowsay, che a sua volta viene colorato da lolcat.
   - exit: Esce dal container (che quindi si spegne).

3. docker ps -a
   Lista i container (anche spenti) per trovare l'ID del container appena usato 
   (es. ef048ccf6bd0).

4. docker commit <ID> ubuntu_with_fortune
   Salva lo stato del container modificato in una nuova immagine locale chiamata 
   'ubuntu_with_fortune'.

5. docker tag ... / docker push ...
   Rinomina l'immagine seguendo la convenzione Docker Hub (user/repo:tag) e la 
   carica online.

6. docker run -e PATH=... -e LC_ALL=C ...
   Esegue l'immagine appena creata.
   - '-e PATH=...': Passa la variabile d'ambiente PATH corretta (perché nel 
     metodo manuale l'export fatto dentro la shell non è persistente).
   - '-e LC_ALL=C': Imposta il locale per evitare errori di codifica caratteri 
     con i programmi Perl (come cowsay/lolcat).
   - '/bin/bash -c ...': Esegue la catena di comandi all'avvio.


--- 2. METODO AUTOMATICO (Dockerfile) ---

Questo è il metodo consigliato per la riproducibilità.

1. cat Dockerfile
   Mostra il contenuto del file di configurazione:
   - FROM ubuntu: Immagine di partenza.
   - RUN ...: Installa i pacchetti in un solo layer.
   - ENV ...: Imposta le variabili d'ambiente (PATH e LC_ALL) in modo PERMANENTE. 
     Non servirà specificarle con '-e' al momento del run.
   - ENTRYPOINT: Definisce il comando che il container eseguirà automaticamente 
     appena avviato.

2. docker build -t ubuntu_with_fortune4 .
   Costruisce l'immagine dal Dockerfile corrente e la chiama 'ubuntu_with_fortune4'.

3. docker run ubuntu_with_fortune4
   Esegue il container. Grazie all'ENTRYPOINT, eseguirà automaticamente la 
   catena 'fortune | cowsay | lolcat' senza bisogno di specificare nulla.


--- 3. ESECUZIONE SU HPC (Cluster Leonardo) ---

Sui cluster HPC (High Performance Computing) non si usa Docker per motivi di 
sicurezza (richiede root). Si usa Singularity (o Apptainer).

1. singularity pull docker://dcesini/hpqc_2025:ubuntu_with_fortune_5.0
   Scarica l'immagine dal Docker Hub e la converte automaticamente nel formato 
   proprietario di Singularity (.sif - Singularity Image Format).
   Nota: Qui viene scaricata la versione taggata '5.0' (esempio del prof).

2. ls *.sif
   Verifica che il file immagine (es. hpqc_2025_ubuntu_with_fortune_5.0.sif) 
   sia stato creato nella directory corrente.

3. singularity run hpqc_2025_ubuntu_with_fortune_5.0.sif
   Esegue il container Singularity. Si comporterà esattamente come il container 
   Docker, eseguendo l'ENTRYPOINT (la mucca colorata).
