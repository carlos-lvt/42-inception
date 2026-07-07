*The very first line must be italicized and read: This project has been created as part
of the 42 curriculum by carlaugu*

## Description

## Instructions


## Resources
- https://contabo.com/blog/containers-vs-virtual-machines/?utm_source=google&utm_medium=cpc&utm_campaign=&utm_term=&utm_content=&gad_source=1&gad_campaignid=23616421152&gbraid=0AAAAAD_Qy-e1xbEWXAyd7DXsLDl-CUD1f&gclid=CjwKCAjwpK3SBhASEiwAtV1SPERAFRWg-YY5FpxSOK76i-Euk91-i9yR48v6MqRen2F16kYD_WXAdhoCAtUQAvD_BwE

- https://docs.docker.com/get-started/get-docker/


## Virtual Machines vs Docker

**Virtual Machine**: A fully isolated environment emulating a separate physical machine. Runs its own guest OS and kernel, provisioned and managed by a **hypervisor** (a software layer that virtualizes underlying hardware resources — CPU, memory, storage). Resource-intensive and slower to initialize, as each instance boots a complete OS.

**Docker**: A containerized environment that **shares the host's kernel** rather than running its own. Isolation is achieved via Linux kernel primitives such as **namespaces** (process, network, and filesystem isolation) and **cgroups** (resource allocation and limits). Lightweight and near-instantaneous to start, since no OS boot process is required.

**Summary:** VMs virtualize hardware and run an independent OS; containers virtualize at the OS level, sharing the host kernel while isolating processes.