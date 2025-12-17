<a name="docker-full-guide"></a>
# [containers-exercises.sh](containers-exercises.sh)

## 🐳 Guida Integrale a Docker: dall'Installazione all'Orchestrazione

Questo documento fornisce una spiegazione sequenziale e dettagliata di tutte le operazioni necessarie per gestire l'intero ecosistema Docker su sistemi RHEL 9.3.

---

### 🛠️ 1. Setup dell'Ambiente e Installazione
La procedura copre la configurazione dei repository ufficiali e l'installazione del **Docker Engine**. 
* **Sicurezza:** Viene installato `container-selinux`, vitale per permettere a Docker di operare correttamente sotto le policy di sicurezza di Red Hat. 
* **Accessibilità:** Viene configurato l'utente di sistema affinché possa gestire i container senza privilegi di `sudo` aggiungendolo al gruppo `docker`.
* **Docker Compose:** Installazione manuale del plugin per l'orchestrazione tramite download diretto dei binari da GitHub.



### 🚀 2. Operazioni sui Container e Persistenza (Commit)
Viene illustrato il ciclo di vita dei container:
* **Esecuzione:** Differenza tra container temporanei ed esecuzioni interattive con shell.
* **Modifica e Salvataggio:** Poiché i container sono effimeri, ogni modifica interna (come l'installazione di pacchetti) viene salvata permanentemente tramite il comando `docker commit`, creando una nuova immagine personalizzata.
* **Distribuzione:** Procedure di `tagging` e `push` per caricare le proprie immagini su **Docker Hub**.

### 🏗️ 3. Automazione con Dockerfile
Passaggio dalla modifica manuale alla creazione automatizzata di immagini. 
* **Build:** Uso di un `Dockerfile` per configurare un Web Server Apache su base Ubuntu.
* **Networking:** Mapping delle porte (es. `8080:80`) per rendere i servizi interni al container raggiungibili tramite l'IP pubblico della VM.



### 💾 4. Gestione Dati e Orchestrazione (Compose)
Approfondimento sulla persistenza dei dati e la gestione di stack complessi:
* **Volumi:** Differenza tra **Bind Mounts** (collegamento a cartelle locali) e **Managed Volumes** (spazi isolati gestiti da Docker).
* **Portabilità:** Metodi per esportare immagini in formato `.tar` per il trasferimento su server offline.
* **Docker Compose:** Utilizzo di file YAML per avviare contemporaneamente più servizi interconnessi (es. **WordPress + Database MySQL**), definendo reti isolate (`frontend`/`backend`) e dipendenze di avvio.



---

**Comandi di Manutenzione:** La guida conclude con le procedure di `prune` per la pulizia del sistema, rimuovendo container fermi, reti orfane e cache di build per liberare spazio su disco.

---
<a name="docker-singularity-guide"></a>
# [cosway.sh](cosway.sh)

## 🐳 Docker personalizzato e Portabilità su HPC (Leonardo Cluster)

Questa guida illustra il passaggio critico dalla creazione di un'immagine personalizzata su una macchina locale/cloud (Docker) alla sua esecuzione su supercomputer ad alte prestazioni (HPC) tramite **Singularity**.

---

### 🛠️ 1. Creazione Immagine: Metodo Manuale vs Dockerfile
Esistono due approcci per personalizzare un'immagine base (es. Ubuntu):
* **Metodo Manuale (Commit):** Si entra in un container interattivo, si installano i pacchetti (`fortunes`, `cowsay`, `lolcat`) e si "fotografa" lo stato finale con `docker commit`. È un metodo rapido ma poco riproducibile, poiché richiede di passare manualmente le variabili d'ambiente (`PATH`, `LC_ALL`) ad ogni avvio.
* **Metodo Automatico (Dockerfile):** Si definisce un file di testo con le istruzioni. È il metodo standard perché garantisce la riproducibilità. L'uso di `ENV` nel Dockerfile rende le variabili d'ambiente permanenti, mentre l' `ENTRYPOINT` definisce il comportamento predefinito del container (es. la pipe `fortune | cowsay | lolcat`).



---

### 🏗️ 2. Dall'ambiente locale al Cloud (Docker Hub)
Una volta creata l'immagine, questa deve essere resa disponibile globalmente. 
1.  **Tagging:** Si rinomina l'immagine seguendo il formato `utente/repository:versione`.
2.  **Push:** Si carica l'immagine su **Docker Hub**. Questo passaggio è essenziale per permettere ai cluster remoti di scaricare il software configurato.

---

### 🚀 3. Esecuzione su HPC con Singularity
Sui cluster di calcolo scientifico come **Leonardo**, Docker non può essere utilizzato perché richiede privilegi di amministratore (root), rappresentando un rischio di sicurezza. Si utilizza quindi **Singularity** (o Apptainer).

* **Conversione Immagine:** Singularity non usa i layer di Docker ma un singolo file binario compresso chiamato **SIF** (*Singularity Image Format*). Il comando `singularity pull` scarica l'immagine da Docker Hub e la converte automaticamente in un file `.sif`.
* **Sicurezza e Privilegi:** Singularity esegue i processi con l'identità dell'utente che lancia il comando, garantendo la compatibilità con gli scheduler di job (come Slurm) tipici degli ambienti HPC.
* **Esecuzione:** Il comando `singularity run` rispetta le configurazioni definite originariamente nel Dockerfile (come variabili d'ambiente ed Entrypoint), garantendo che il software funzioni in modo identico sia sul laptop che sul supercomputer.



---

**Conclusione:** Questo workflow permette a un ricercatore di preparare l'ambiente di calcolo sul proprio PC e di "spedirlo" pronto all'uso su un'infrastruttura di calcolo massivo, risolvendo definitivamente i problemi di dipendenze software.

----
<a name="udocker-guide"></a>
# [udocker.sh](udocker.sh)

## 🐳 Esecuzione di Container senza Privilegi: Guida a udocker

Questa procedura illustra come utilizzare **udocker**, uno strumento fondamentale per eseguire container Docker in ambienti dove l'utente non possiede i privilegi di root (amministratore), come nei cluster HPC o nei server condivisi.

---

### 🛠️ 1. Cos'è udocker e perché usarlo
A differenza del motore Docker standard, che richiede un demone in esecuzione come root, **udocker** è un tool interamente in "User Space". Utilizza diverse tecnologie di esecuzione (come **PRoot** o **Fakeroot**) per simulare l'ambiente del container senza mai violare la sicurezza del sistema ospite.



### 🏗️ 2. Installazione in Spazio Utente
L'installazione non richiede pacchetti di sistema (`yum` o `apt`):
* **Download ed Estrazione:** Si scaricano i binari direttamente nella propria cartella utente.
* **Configurazione PATH:** Viene aggiunto il percorso dell'eseguibile alla variabile `$PATH` per rendere il comando disponibile nel terminale.
* **Self-Install:** Al primo avvio (`udocker install`), il tool scarica i motori di esecuzione necessari nella cartella nascosta `~/.udocker`.

---

### 🚀 3. Workflow: Pull ed Esecuzione
Il funzionamento di udocker ricalca fedelmente la sintassi di Docker, rendendo la curva di apprendimento quasi nulla:
* **Pull:** Scarica le immagini dal **Docker Hub** proprio come farebbe Docker. Le immagini vengono estratte e convertite in una struttura di directory leggibile dall'utente.
* **Run:** Avvia il container mantenendo l'identità dell'utente. Se l'immagine originale possiede un `ENTRYPOINT` (come nel caso del container "fortune | cowsay | lolcat"), udocker lo eseguirà automaticamente.



---

### In sintesi: I vantaggi di udocker
* **Zero Privilegi:** Non richiede `sudo` né installazioni a livello di sistema.
* **Compatibilità:** Permette di portare container creati su PC/Mac direttamente su server dove Docker è vietato per motivi di policy.
* **Isolamento:** Ogni utente gestisce le proprie immagini e i propri container in modo totalmente separato e sicuro.
