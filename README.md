# Print Gateway Docker Image

Print Gateway is a lightweight Docker service designed to securely receive PDF files from external networks and forward them to a local CUPS print server. It acts as a safe intermediary between external clients and CUPS, enabling controlled printing from outside the local network.

## 🚀 How It Works

1. The service accepts an HTTP request whose body contains a PDF file. The filename is taken from the `X-Filename` header.
2. The file is saved to `/tmp/uploads`, and a task descriptor is created in `/tasks/pending`.
3. A watcher monitors new tasks and triggers `print.sh`, which forwards the file to the CUPS server.
4. On success, the task is moved to `/tasks/printed`.  
   On failure, up to 3 retries are performed: after 1 minute, 5 minutes, and 10 minutes.
5. A daily cleanup removes all files older than 24 hours.

> Print Gateway only handles file delivery and task queue management.  
> It does **not** control the actual printing process.

---

## 📡 API

### POST `/print`

Used to submit a PDF file for printing.

### Requirements:
- Request body: binary PDF (`application/pdf`)
- Header `X-Filename`: the name of the file (required)

### Example:

```bash
curl -X POST http://localhost:8502/print \
  -H "Content-Type: application/pdf" \
  -H "X-Filename: document.pdf" \
  --data-binary @document.pdf
```
#### Responses:
200 OK — task created and placed into /tasks/pending

400 Bad Request — missing X-Filename or invalid PDF

500 Internal Server Error — failed to save file or create task

## 📋 Requirements
A running CUPS server (container or host)

Environment variables CUPS_HOST and CUPS_PORT must point to it

Mounted directory /tasks is mandatory

## 🏗 Build & Run
Build the image
bash
docker build -t print-gateway .
#### ▶️ Run the container
Minimal example:

```bash
docker run -d \
  --name print-gateway \
  -e CUPS_HOST=localhost \
  -e CUPS_PORT=631 \
  -v /path/on/host/tasks:/tasks \
  -p 8502:8502 \
  print-gateway
```
Mandatory directory
The /tasks directory must be mounted.
On first run, the following subdirectories are created automatically:

```
/tasks/pending
/tasks/retry
/tasks/printed
/tasks/failed
```
### 🔐 Optional: IP Access Restriction
To restrict access using Nginx and an IP whitelist:

```bash
docker run -d \
  --name print-gateway \
  -e CUPS_HOST=localhost \
  -e CUPS_PORT=631 \
  -v /path/on/host/tasks:/tasks \
  -v /path/on/host/whitelist.conf:/whitelist.conf \
  -p 8502:8502 \
  print-gateway
  ```
