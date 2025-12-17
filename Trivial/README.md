
# 📂 Documentazione Cartella: trivial/

In questa cartella sono raccolti gli script relativi alla gestione dello storage e ai benchmark di ricerca bioinformatica.
| Argomento | Link Rapido | Descrizione |
| :--- | :--- | :--- |
| 💾 **Storage Ops** | [Vai alla sezione](#storage-section) | Partizionamento, formattazione e mount (nella cartella trivial/). |
| 🧬 **Bio Tools** | [Vai alla sezione](#bio-tools-section) | Benchmark Trivial, BLAST e BWA (nella cartella trivial/). |

<a name="storage-section"></a>
# [attaching_a_volume.sh](attaching_a_volume.sh)
## Guida: Partizionamento, Formattazione e Mount di un Volume

Questa procedura descrive i passaggi necessari per rendere operativo un nuovo disco rigido (o un volume cloud come AWS EBS) all'interno di un sistema Linux. Senza questi passaggi, il disco viene visto dal sistema come "hardware presente" ma non è utilizzabile per salvare file.



---

### 1. Identificazione e Partizionamento (`fdisk`)
Il primo passo è individuare il device grezzo (es. `/dev/nvme1n1`) e creare una partizione.
* **Perché partizionare?** Anche se si vuole usare l'intero disco, creare una tabella delle partizioni è una best practice per la compatibilità e la gestione futura dei dati.
* **Comandi chiave:** Con `n` si crea una nuova partizione, con `w` si scrivono definitivamente le modifiche sul disco.

### 2. Formattazione: Creare il File System (`mkfs.ext4`)
Un disco partizionato è come un magazzino vuoto senza scaffali. La formattazione crea la struttura logica necessaria.
* **ext4:** È uno dei filesystem più usati e robusti in ambito Linux.
* **Nota Tecnica:** La formattazione si applica alla **partizione** (es. `/dev/nvme1n1p1`) e non al disco intero.

---

### 3. Il Punto di Mount (`mkdir` & `mount`)
In Linux non esistono le lettere delle unità (come `C:` o `D:`). I dischi vengono "innestati" nell'albero delle directory esistente.
* **Mount Point:** Creando la cartella `/data2` e montandoci il disco, diciamo al sistema: "Tutto quello che metto in questa cartella deve essere salvato fisicamente sul nuovo volume".

### 4. Persistenza: Il file `/etc/fstab`
Questo è il passaggio più critico. Senza questa configurazione, al riavvio del server il disco non verrebbe montato automaticamente.
* **defaults:** Imposta le opzioni standard (lettura/scrittura, montaggio all'avvio).
* **0 0:** Indica al sistema di non eseguire il dump (backup) e di non controllare il disco all'avvio con fsck (per velocizzare il boot).
* **daemon-reload:** Notifica a `systemd` (il gestore del sistema) che la tabella dei dischi è cambiata.



---

### In sintesi: Perché è importante?
Questa procedura trasforma un volume "vuoto" in uno spazio di archiviazione persistente e sicuro. È la base per ospitare database, repository di file o le directory condivise (NFS) che verranno poi utilizzate dal cluster HTCondor.

---
<a name="bio-tools-section"></a>
# [trivial_blast_bwa_handson.sh](trivial_blast_bwa_handson.sh)
## Analisi Bioinformatica: Trivial Search, BLAST e BWA

Questa esercitazione confronta diverse metodologie per la ricerca e l'allineamento di sequenze di DNA (Human Genome HG19). Si passa da un approccio a forza bruta ("Trivial") a strumenti altamente ottimizzati per i Big Data genomici.



---

### PARTE 1: Ricerca "Ingenua" vs BLAST

#### 1. Trivial Search (Brute Force)
Prima di usare tool avanzati, testiamo un approccio **Brute Force** con uno script Python che cerca una stringa carattere per carattere.
* **Baseline:** Serve a dimostrare l'inefficienza dei metodi non ottimizzati su grandi volumi di dati.
* **Integrità:** Viene calcolato l'**MD5Sum** del file di testo (`shining.txt`) per assicurarsi che la copia locale sia identica alla "Golden Copy" originale.

#### 2. BLAST (Basic Local Alignment Search Tool)
BLAST è lo standard de facto per l'allineamento euristico.
* **Installazione:** Avviene tramite pacchetto RPM (`yum localinstall`).
* **Indicizzazione:** Per funzionare velocemente, BLAST non legge il genoma come un file di testo, ma usa un **Indice** pre-calcolato (creato con `makeblastdb`).
* **Memory Caching:** Un aspetto critico è la gestione della RAM. La prima esecuzione è lenta (I/O da disco), le successive sono veloci (cache RAM). Usiamo `drop_caches` per pulire la memoria e misurare le prestazioni reali del disco.



---

### PARTE 2: Compilazione ed Esecuzione BWA

#### 1. Compilazione dai Sorgenti (Install from Source)
BWA viene installato compilando il codice C. Questo è lo scenario tipico nei centri di calcolo (HPC).
* **Dipendenze:** Richiede `gcc` e le librerie `zlib`.
* **Il Patching:** Un passaggio fondamentale è la modifica manuale del codice sorgente (da `const` a `extern const` alla riga 33) per correggere un'incompatibilità tra versioni vecchie del software e compilatori moderni. Senza questa "patch", il comando `make` fallirebbe.

#### 2. Workflow di Allineamento BWA
BWA è più veloce di BLAST ma richiede un processo in due fasi (Two-Step Workflow):
1.  **Fase `aln` (Backtrack):** Genera un file binario `.sai` (Suffix Array Index). Questo file non è leggibile dall'uomo ma contiene le coordinate matematiche dell'allineamento.
2.  **Fase `samse` (SAM Generation):** Converte il file `.sai` nel formato standard **SAM** (Sequence Alignment Map), che è un file ASCII leggibile contenente l'allineamento finale sul genoma umano.



---

### In sintesi: Perché questa distinzione?
* **Trivial Search:** Utile solo per capire il problema.
* **BLAST:** Ottimo per cercare somiglianze tra poche sequenze (approccio generalista).
* **BWA:** Lo strumento d'elezione per mappare milioni di letture (Short Reads) contro un intero genoma, grazie alla trasformata di Burrows-Wheeler che riduce drasticamente l'uso di memoria e tempo CPU.
