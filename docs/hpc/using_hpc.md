<h1 align="center">Guide to using PBS and HPC for your work</h1>

This guide is designed to help you get started with using PBS (portable Batch System) and an HPC (High perfomance computing) system effectively for your job. This article contains the necessary instructions to start and troubleshoot if any problem arises.

## TL;DR 
All the major commands and scripts mentioned in this article and some more.

### Job Submission
- `qsub <script_name>: Submits a job to the queue
### Job Monitoring
- `qstat`: Lists all the jobs and their status
- `qstat -f  <job_id>`: Details about a particular job
- `qstat -u <user_name>`: Jobs submitted by a user
### Job Management
- `qdel <job_id>`: To delete a job
### Node Information
- `pbsnodes` : Displays information on compute nodes
- `pbsnodes <node_name>`: Displays information about a particular node
### Queue Management
- `qstat -q`: Lists all queues
- `qstat -Q`: Detailed queue usage
### Resource Allocation
- `qstat -r`: Shows running jobs with resource details
### General commands
- `tracejob <job_id>`: Traces a job's history for debugging

## Table of Contents
1. [Introduction to HPC and PBS](#intro)
2. [How PBS and HPC work](#howitwork)
3. [Basic Concepts and Terminology](#basicconcepts)
4. [Logging in to the HPC](#logging)
5. [Writing and Submitting PBS jobs](#jobscript)
6. [Monitoring and Managing Jobs](#monitoring)
7. [Debugging common issues](#debug)
8. [Tips and Best Practises](#tips)
9. [References](#ref)
10. [Authors](#authors)

## <a name=intro>1. Introduction to HPC and PBS </a>

High Perfomance Computing (HPC) refers to cluster of computers that are connected together to perform computations much faster than a typical workstation. Portable Batch System (PBS) is a workload management system or simply a job scheduler that simplifies the job of submitting, scheduling and monitoring the jobs on an HPC.

---

## <a name=howitwork>2. How PBS and HPC works </a>

The basic structure of an HPC is a system consisting of several interconnected components:
    1. **Master node**: Serves as the central hub. This is where you will be able to log in, manage files and submit jobs.
    2. **Compute nodes**: Actual machines in which the computation takes place. 
    3. **Shared file system**: A common storage system that allows seamless access to your data across all nodes. 

PBS operates as an intermediary between users and the HPC system. When you submit a job using PBS, it is added to a queue and scheduled based on resource availability and priority. PBS distributes the workload effectievely across all the compute nodes. When a node becomes available, the job is submitted to that node by PBS. It should be noted that you should *NOT* run codes directly on the master node, as it is a shared node and its only task is to manage files and prepare scripts.

NB: The number of nodes of your cluster can be found out by running the command `pbsnodes` it will give the information on how many nodes are there and the status of these nodes. All the commands will be listed later in the article.

---

## <a name=basicconcepts>3. Basic Concepts and Terminology </a>

These are some key terms associated with using HPC. It is important to understand these for effectievely using the cluster.

- **Job**: A script or command submitted to PBS for excecution.
- **Queue**: A list of tasks waiting to run. PBS schedules jobs based on the queue.
- **Node**: An individual server (or a computer) within the HPC cluster.
- **Walltime**: The maximum duration a job is allowed to run.
- **CPU Cores**: The procesing units within a computer (in this case, each node). Allocating more cores allows for parallel execution of tasks, which can significantly speed up multithreaded programs (if your job can be run parallely - for example it is repetitively doing a particular tak for a set of files, it can be run simulataneously to increase the speed).
- **Memory (RAM)**: The space availble for your job's data and processes while they run. It stores the data temporarily for the runtime. Insufficient memory can cause jobs to crash. So it is very necessary to make the job you are running efficient.
- **Storage**: Disk space used to store input files, temporary data, and job outputs.

---

## <a name=logging>4. Logging in to the HPC </a>

To get started, log in to your account in the HPC system using secure shell (SSH):
```bash
ssh your_user_name@hpc_ip_address
```
Once logged in you can navigate to your working directory where you have your scripts and files.

If you have a particular module that you want to call (Modules will be libraries or softwares that you have installed locally on your user), you can use: 
    - `module avail` to see the available modules
    - `module load module_name` in the job script to load the module.

Ensure that all the  necessary modules are loaded in the PBS jobscript to avoid runtime errors.

--- 

## <a name=jobscript>5. Writing and Submitting PBS Jobs </a>

### Transferring files into HPC
For transferring files, linux command line tool `scp` (secure copy) can be used. First get the directory locations of where the files are and where it should be copied to.

Then run this script in your local machine:
```bash
scp <location of file to be copied> <location to which it should be copied>
```
The important thing to notice here is while specifiying the location in your HPC account, the location should be prefixed by `your_user_name@hpc_ip_address:`. For example:
```bash
scp /Users/user_name/file user_name@hpc_ip_address:/home/user/destination
```
Also while transferring folders, make sure to add `-r` tag to recursively copy files inside the folder.

```bash
scp -r user_name@hpc_ip_addr:/home/user/folder .
```
You can see that in the above example, The destination folder is represeented as ".". It means current working directory. The folder will be transferred to the directory you are in your local machine.

### MOdifying files in HPC
For modifying and making changes to the scripts and files in HPC, `vim` or `nano` text editors can be used. `vim` has a steep learning curve so `nano` is recommended. To edit a particular file, just type `nano <file_name>` to edit that particular file. Necessary keybindings to save and exit nano will be displayed in the bottom of the text editor.

### Writing job script
A PBS jobscript is essentially a bash script that contains special directives to specify the resource your job requires and some other details. This includes a header region that contains the job name, walltime, memory, number of nodes etc.: 

### Example PBS Script:
```bash
#!/bin/bash
#PBS -N job_name            # Job name
#PBS -l nodes=1:ppn=4       # Describing nodes and processors required
#PBS -l walltime=02:00:00   # Walltime
#PBS -l mem=8gb             # RAM
#PBS -q queue_name          # Specifying the queue
#PBS -o output.log          # Stores the output of the job
#PBS -e output.err          # stores the error messages from the job

# Load required modules
module load module_name

# change the directory to your work directory (where the job is submitted from)
cd $PBS_O_WORKDIR 

# Run your command
sh sequence_alignment_script.sh

```

This job will have the name `job_name`, uses 1 node with 4 processor cores, 8gb of memory, and a two-hour runtime. Outputs and errors are written to output.err and output.log

To submit this jobscript:
```bash
qsub jobscript_run.sh
```
PBS will assign the job a unique ID, which can be used for tracking the job.

---

## <a name=monitoring>6. Monitoring and Managing Jobs </a>

- To view all jobs:
```bash
qstat
```
- Get detailed information about a specific job:
```bash
qstat -f <job_id>
```
- To see the jobs that you are running
```bash
qstat -u $USER     # Shows all your jobs
qstat -wau $USER   # Shows the result neatly
qstat -xwau $USER  # Shows information on jobs that has already finished
qstat -n1rwu $USER # Shows the location of the job file
```
- Cancelling a job:
```bash
qdel <job_id>
```
---

## <a name=debug>7. Debugging Common Issues </a>

If your job doesn't start, check:
- output.err file: The script might contain some error which causes it to fail.
- Queue status: the queue might be full.
- Resources: You may have requested excessive resources.

## <a name=tips>8. Tips and Best Practises </a>
- Start with a small test to verify your jobscript.
- Optimise resource requests to avoid delays.
- Organize output and error file with descriptive names to avoid confusion.
- Document log files for future references.
- Leverage modules if you need a special version of a library or software that your job requires.

## <a mame=ref>9. References and Further reading </a>
- [Using HPC](https://www.weizmann.ac.il/chemistry/chemfarm/)
- [PBS documentation](https://2021.help.altair.com/2021.1.2/PBS%20Professional/PBSUserGuide2021.1.2.pdf)
- [Some basic linux commands for using HPC](https://nusit.nus.edu.sg/wp-content/uploads/2019/09/unixcom.pdf)

## <a name=authors>Authors</a>
This documentation was created by [Devanarayanan P](https://github.com/kaldiraz)
**This guide was created with the assistance of ChatGPT, developed by OpenAI**


