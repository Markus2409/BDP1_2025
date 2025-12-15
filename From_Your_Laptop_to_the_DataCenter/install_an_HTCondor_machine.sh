================================================================================
SPIEGAZIONE CONFIGURAZIONE CLUSTER HTCONDOR SU AWS
================================================================================

Questa esercitazione guida alla creazione di un cluster HTCondor composto da 3 nodi 
distinti: un Central Manager (il "cervello"), un Submit Node (il punto di accesso) 
e un Execute Node (il lavoratore).

--- 1. PREPARAZIONE INFRASTRUTTURA (AWS & NFS) ---

- create 3 VMs on AWS
  Si creano tre istanze EC2. 
  - Central Manager e Submit Node usano 't3_small' (bastano per la gestione).
  - Execute Node usa 't3_medium' perché richiede più potenza di calcolo (CPU/RAM) 
    per eseguire i job scientifici.

- (make available the /data2 directory to all the VMs, i.e. USE NFS!!)
  È fondamentale che tutti i nodi vedano gli stessi file. Si deve configurare 
  NFS (come visto nell'esercizio precedente) per condividere la cartella '/data2' 
  tra le macchine.

--- 2. INSTALLAZIONE HTCONDOR (Script get.htcondor.org) ---

Lo script utilizzato scarica e installa automaticamente HTCondor configurando i ruoli.

A. CENTRAL MANAGER
   curl -fsSL https://get.htcondor.org | sudo GET_HTCONDOR_PASSWORD="BDP1_2025" /bin/bash -s -- --no-dry-run --central-manager <IP>
   - Scarica lo script di installazione ufficiale.
   - Imposta la password di sicurezza del cluster ("BDP1_2025").
   - Il flag '--central-manager' configura questa macchina come orchestratore del cluster.
   - <IP> deve essere l'indirizzo IP privato della macchina stessa.

B. SUBMIT NODE
   curl ... --submit <the_central_manager_private_IP>
   - Il flag '--submit' configura questa macchina per permettere agli utenti di sottomettere i job.
   - È necessario specificare l'IP del Central Manager affinché il nodo sappia a chi rivolgersi.

C. EXECUTE NODE
   curl ... --execute <the_central_manager_private_IP>
   - Il flag '--execute' configura questa macchina come Worker Node (dove girano i job).
   - Si collega al Central Manager specificato.

--- 3. VERIFICA ---

- condor_status
  Mostra lo stato del cluster. Se tutto funziona, dovresti vedere l'Execute Node elencato 
  come risorsa disponibile.

- ps auxwf
  Visualizza i processi attivi ad albero. Utile per vedere i demoni di Condor (condor_master, 
  condor_collector, condor_negotiator, ecc.) in esecuzione.

--- 4. CONFIGURAZIONE AVANZATA (Slot Types) ---

HTCondor divide le risorse (CPU) in "Slot". Di default crea uno slot per ogni core. 
Questa configurazione personalizza come le risorse vengono divise.

- /etc/condor/config.d/01-execute.config
  File di configurazione creato sull'Execute Node.
  - use FEATURE: StaticSlots: Indica di usare slot statici invece che dinamici (partitionable).
  - SLOT_TYPE_1 = cpus=2, NUM_SLOTS_TYPE_1 = 1: Crea 1 slot che consuma 2 CPU.
  - SLOT_TYPE_2 = cpus=1, NUM_SLOTS_TYPE_2 = 2: Crea 2 slot che consumano 1 CPU ciascuno.
  
  In totale, su una macchina con 4 vCPU, avremo 3 slot disponibili con capacità diverse.

- condor_reconfig / systemctl restart condor
  Ricarica la configurazione per applicare le modifiche agli slot.

--- 5. SICUREZZA DI RETE (AWS Security Groups) ---

- All TCP 0 - 65535 from same security group
  HTCondor usa porte dinamiche per comunicare tra i vari demoni. È essenziale aprire 
  TUTTE le porte TCP tra le macchine che fanno parte dello stesso Security Group 
  (tra di loro si devono fidare ciecamente).

- All ICMP-IPv4
  Permette il ping tra le macchine per diagnostica.
