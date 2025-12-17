# 📚 Indice della Documentazione

| Argomento | File di Riferimento | Descrizione |
| :--- | :--- | :--- |
| 🌐 **Shared Storage** | [NFS Client-Server](#howto-install-an-nfs-client-server-sh) | Configurazione del Network File System per dati condivisi. |
| 📊 **Job Submission** | [HTCondor Batch Job](#howto-submit-a-batch-job-with-htcondor-sh) | Guida all'uso dei comandi Condor e gestione code. |
| 🧬 **Workflow Logic** | [Job Anatomy](#pseudocode-for-a-batch-job-txt) | Struttura Prologue-Main-Epilogue e best practices. |
| ☁️ **Cloud Cluster** | [HTCondor AWS](#install_an_htcondor_machine-sh) | Setup di un cluster distribuito su istanze EC2. |

---

# [Howto-Install-an-NFS-Client-Server.sh](Howto-Install-an-NFS-Client-Server.sh)
## Spiegazione Configurazione Network File System (NFS)

Questa procedura serve a configurare **NFS (Network File System)**, un protocollo che permette di condividere directory e file su una rete. In un ambiente distribuito (come un cluster di calcolo), NFS è fondamentale perché permette a diversi nodi (Client) di accedere agli stessi dati centralizzati su un unico server.



---

### 1. Il Cuore del Sistema: nfs-utils e rpcbind (Server Punti 1-3)
Per far funzionare NFS non basta un solo servizio, ma una collaborazione:
* **nfs-utils:** Contiene i programmi necessari per gestire le richieste di file.
* **rpcbind:** È fondamentale perché NFS usa chiamate RPC (Remote Procedure Call). Immaginalo come un centralino che indirizza correttamente le richieste del client verso il servizio giusto sul server.

### 2. Definire le Condivisioni: /etc/exports (Server Punti 5-7)
Il file `/etc/exports` è la "lista di accesso" del server. Qui decidi chi può vedere cosa:
* **Permission (rw):** Permette al client di scrivere file, non solo di leggerli.
* **Sync vs Async:** Con `sync`, il server conferma l'operazione solo quando i dati sono scritti fisicamente sul disco. È più sicuro contro i guasti improvvisi (es. blackout), anche se leggermente più lento.
* **exportfs -r:** È il comando magico. Permette di aggiornare le condivisioni "a caldo" senza disconnettere gli utenti che stanno già lavorando.



---

### 3. Il Lato Client: Montare la risorsa (Client Punti 1-2)
Il client deve essere istruito per "vedere" la cartella remota.
* Anche il client deve avere `nfs-utils` installato, altrimenti non saprebbe come interpretare i pacchetti di dati che arrivano dal server NFS.
* Il comando `mount -t nfs` dice al sistema operativo: "Prendi quella cartella che sta sull'IP del server e falla apparire qui come se fosse una cartella locale".

### 4. Persistenza con /etc/fstab (Client Punto 5)
Come abbiamo visto per i dischi AWS o locali, il mount manuale sparisce al riavvio.
* Inserire la riga nel file `/etc/fstab` del client è **obbligatorio** se vuoi che il collegamento sia permanente.
* Se il server NFS non è raggiungibile all'avvio e non sono impostate opzioni specifiche, il client potrebbe metterci molto tempo a partire (va in timeout cercando il disco remoto).

---

### In sintesi: a cosa serve tutto questo?
NFS è la soluzione ideale per la **Shared Storage** in una rete locale. Mentre **WebDAV** (visto in precedenza) è più adatto per l'uso via Web/Internet e browser, **NFS** è molto più veloce e performante per far comunicare tra loro i server di un data center o i nodi di un'infrastruttura Big Data.

----
# [Howto-submit-a-batch-job-with-HTCondor.sh](Howto-submit-a-batch-job-with-HTCondor.sh)
## Gestione dei Job con HTCondor

**HTCondor** è un sistema di gestione del carico di lavoro (WMS/Batch System) specializzato per l'**High Throughput Computing (HTC)**. È progettato per gestire migliaia di job indipendenti sfruttando al massimo la potenza computazionale distribuita.



---

### 1. Il File di Descrizione del Job (.job) (Punto 5)
Il file `.job` è il documento più importante. Non è uno script, ma una lista di direttive per HTCondor. Specifica:
* **Executable:** Quale programma lanciare.
* **Input/Output/Error:** Dove salvare i log e i risultati.
* **Requirements:** Requisiti hardware (es. "Voglio un nodo con almeno 4GB di RAM").
* **Queue:** Quante volte lanciare quel lavoro.

### 2. Ispezionare il Cluster: condor_status (Punto 6)
Prima di inviare un lavoro, devi sapere se c'è spazio. 
* `condor_status` interroga il "Collector" (il database centrale di Condor) per vedere quali macchine sono `Unclaimed` (libere) o `Claimed` (occupate).



---

### 3. Il Ciclo di Vita del Job (Punti 7-11)
Quando sottometti un job, attraversa diversi stati:
* **Submission (`condor_submit`):** Il job viene inserito nella coda locale del "Submit Node".
* **Idle (In attesa):** Il job è in coda. Se resta qui troppo tempo, si usa `condor_q -better-analyze` per capire se i requisiti richiesti sono troppo alti per le macchine disponibili.
* **Running (In esecuzione):** HTCondor ha trovato un match e ha "spinto" (Eager) o il nodo ha "pullato" (Lazy/Pilot) il job.
* **Completed:** Il job finisce. I risultati vengono trasferiti indietro e il job passa in `condor_history`.

### 4. Debugging e Log (Punti 12-13)
HTCondor genera tre file fondamentali per ogni job:
1. **.out (Stdout):** Quello che il tuo programma scriverebbe normalmente a video.
2. **.error (Stderr):** Messaggi di errore del codice (es. "file not found" in Python).
3. **.log (Event Log):** Il diario di bordo di Condor. Ti dice a che ora è iniziato il calcolo, su quale macchina è andato e quanta memoria ha usato davvero.

---

### 5. Esempio Bioinformatico: Allineamento BWA (Punti 14-18)
L'esempio `hg` (Human Genome) mostra un caso d'uso reale:
* Si usa uno script Python (`align.py`) come "wrapper" per lanciare il software scientifico `BWA`.
* Questo tipo di workflow è tipico dell'HTC: si lanciano centinaia di piccoli allineamenti in parallelo su nodi diversi invece di uno solo gigante.
* L'uso di `md5.txt` alla fine è una **Best Practice**: serve a garantire l'integrità dei dati (Checksum) dopo il trasferimento dal nodo remoto alla tua cartella.

---

### In sintesi: Perché usare HTCondor?
HTCondor è l'intelligenza che automatizza la distribuzione dei lavori. Invece di collegarti a 10 server diversi e lanciare i comandi a mano, scrivi un file di descrizione e lasci che Condor trovi la risorsa migliore, gestisca i fallimenti e ti riporti i file di output.
----

# [Pseudocode-for-a-batch-job.txt](Pseudocode-for-a-batch-job.txt)
## Anatomia di un Job: Prologue, Main ed Epilogue

In un'infrastruttura distribuita, un Job non è un semplice comando isolato, ma un workflow diviso in tre fasi critiche. Questo approccio garantisce che la potenza di calcolo non venga sprecata su nodi mal configurati o con dati corrotti.



---

### 1. PROLOGUE: La Preparazione (Fail Early)
Il prologo serve a verificare che il nodo sia pronto. La filosofia è: **se qualcosa deve fallire, deve farlo subito** prima di occupare la CPU per ore.
* **Health Check dell'Eseguibile:** Se il software (es. BWA) non c'è, lo installa al volo.
* **Strategia dei Dati (Data Distribution):** I Database pesanti (es. Genoma Umano da 3GB) non viaggiano con il job (Input Sandbox), ma devono essere già presenti sul nodo o scaricati tramite canali dedicati.
* **Integrità (MD5Sum):** Verifica che i dati sul nodo non siano stati danneggiati durante il trasferimento. Se il checksum non torna, il job abortisce immediatamente.

### 2. MAIN: L'Esecuzione (Il Cuore)
È la fase in cui gira l'algoritmo scientifico. Nel corso vengono spesso confrontati due standard:
* **BLASTn:** Storico, versatile ma più lento (approccio euristico/brute force).
* **BWA (Burrows-Wheeler Aligner):** Moderno, estremamente veloce e ottimizzato per mappare milioni di piccole sequenze contro un genoma di riferimento.



---

### 3. EPILOGUE: Chiusura e Pulizia
Una volta terminato il calcolo, il job non è finito finché i dati non sono al sicuro e il nodo è pulito.
* **Integrità in uscita:** Calcola l'MD5 dell'output per garantire che il file che arriverà all'utente sia identico a quello prodotto.
* **Compressione (La Regola d'Oro):** "Spostare file ASCII enormi non compressi è un crimine". Comprimere (Gzip) riduce drasticamente l'uso della banda di rete e i tempi di trasferimento della Output Sandbox.
* **Housekeeping (Clean All):** Il job deve cancellare i file temporanei. In un sistema condiviso, lasciare il disco del nodo pieno è un comportamento che può bloccare l'intero cluster.

---

### In sintesi: Perché questa struttura?
Senza Prologo ed Epilogo, un'infrastruttura Big Data collasserebbe. Il **Prologo** evita il "Black Hole Effect" (job che falliscono a catena perché manca un file), mentre l'**Epilogo** ottimizza la rete e garantisce che l'utente riceva dati validi, non corrotti.

----
# [install_an_HTCondor_machine.sh](install_an_HTCondor_machine.sh)
## Configurazione Cluster HTCondor su AWS

Questa guida illustra la creazione di un cluster **HTCondor** distribuito su tre istanze **AWS EC2**. Il sistema è progettato per gestire carichi di lavoro scientifici (HTC) attraverso un'architettura a ruoli distinti.



---

### 1. Architettura dei Nodi (Infrastruttura AWS)
Il cluster è composto da tre componenti fondamentali che comunicano tra loro:

1.  **Central Manager (Il Cervello):** Orchestre il cluster. Riceve le offerte di risorse dai nodi di calcolo e le richieste dai nodi di sottomissione.
2.  **Submit Node (Il Punto di Accesso):** Dove l'utente carica i file e lancia `condor_submit`.
3.  **Execute Node (Il Lavoratore):** Il nodo che possiede le CPU e la RAM per eseguire i task.

**Nota sulle Performance:** Abbiamo scelto istanze `t3.medium` per l'Execute Node perché il calcolo scientifico (Main) richiede più risorse rispetto alla semplice gestione (Central/Submit).

---

### 2. Condivisione Dati (NFS)
Un cluster distribuito "sano" deve avere un **File System condiviso**. 
Utilizziamo **NFS** per montare la directory `/data2` su tutte le VM. Questo garantisce che:
* Il codice sorgente sia identico su tutti i nodi.
* I database di riferimento (es. genomica) siano accessibili ovunque senza doverli copiare manualmente ogni volta.

---

### 3. Installazione e Sicurezza
L'installazione avviene tramite lo script ufficiale `get.htcondor.org`. La password `BDP1_2025` funge da chiave di sicurezza per impedire a macchine esterne di unirsi al cluster senza autorizzazione.

**Sicurezza AWS (Security Groups):**
HTCondor non usa una singola porta fissa, ma un range dinamico per far parlare i vari demoni (Collector, Negotiator, Schedd, Startd). 
* **Regola d'oro:** È necessario aprire **tutto il traffico TCP interno** tra i membri dello stesso Security Group per evitare che il firewall blocchi la comunicazione tra il "cervello" e i "muscoli" del cluster.

---

### 4. Gestione delle Risorse: Slot Types
HTCondor permette di partizionare la CPU di un nodo in **Slot**. In questa configurazione abbiamo personalizzato la divisione:
* **Slot Statici:** Dividiamo la macchina in "uffici" di dimensioni fisse.
* **Esempio Configurato:** Abbiamo creato slot con diverse potenze (uno da 2 vCPU e due da 1 vCPU). Questo permette di accogliere contemporaneamente job pesanti e job leggeri, ottimizzando l'occupazione della macchina.



---

### 5. Comandi di Verifica
* `condor_status`: Verifica che l'Execute Node sia apparso nell'elenco delle risorse.
* `ps auxwf`: Permette di vedere l'albero dei processi di Condor. Se vedi i demoni `condor_master` e `condor_collector`, il nodo è vivo.

---

### In sintesi: Perché questo setup su AWS?
Configurare HTCondor su AWS permette di avere un'infrastruttura **scalabile**. Se i job aumentano, basta accendere altri 10 "Execute Nodes", eseguire lo script di installazione puntando all'IP del Central Manager e la tua potenza di calcolo aumenterà istantaneamente.
