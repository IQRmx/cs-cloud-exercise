# CS Cloud Exercise 

## Live Testing Environment
A test environment is already running, where the web application can be accessed to validate its functionality.

- **Instance Name**: `cs-vm`
- **Public IP**: `34.27.111.187`  
- **Database Instance**: `cs-db` (Private IP only)
- **Application URL**:  
  ```
  http://34.27.111.187/index.php
  ```
  Expected output:
  ```
  connected
  ```


## **Project Overview**  
This project builds a simple cloud setup using **Terraform** and **Google Cloud Platform (GCP)**. The infrastructure includes:  

- **VPC & Subnets:**  
  - A custom **Virtual Private Cloud (VPC)** with dedicated subnets for internal traffic.  
  - **VPC Peering** to connect the database to the VM.  
- **NAT Gateway:**  
  - Allows outgoing internet access for internal resources.  
- **Compute Engine VM:**  
  - Runs **Nginx + PHP** and connects to the database.  
- **Cloud SQL (PostgreSQL 14):**  
  - A managed database accessible **only via private IP**.  
- **Firewall Rules:**  
  - **SSH (22):** Admin access.  
  - **HTTP (80):** Allows public access to the web app.  
  - **PostgreSQL (5432):** Open only for the VM inside the VPC.  
- **Test Web App:**  
  - A basic app hosted on the VM to confirm database connectivity.  

---

## Notes
- The database **only has a private IP** for security reasons.
- Firewall rules restrict database access to the VM only.
- If the database is unavailable, the app **does not handle errors**, causing a timeout instead of a custom message.
