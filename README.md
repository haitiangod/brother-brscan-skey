# Brother brscan-skey Docker Container

This Docker container facilitates scanning on Brother MFC printers/scanners. It simplifies the deployment of the Brother drivers and Scan Key Tool on a Docker host, allowing users to manage and initiate scans from their Brother devices easily.

### Features

- Easy configuration of Brother MFC devices for network scanning.
- Centralized storage of scanned documents.
- Customizable PDF conversion settings for optimal image quality and file size.

## Usage

You can run this Docker container using either docker-compose or docker run.

### Run the Docker container with docker-compose (recommended)):

```yaml
version: "3.1"

services:
  brother-brscan-skey:
    image: haitiangod/brother-brscan-skey
    container_name: brother-brscan-skey
    environment:
      - NAME=Scanner
      - MODEL=MFC-L2710DW
      - IPADDRESS=192.168.1.41
      - DENSITY=150
      - COMPRESS=jpeg
      - QUALITY=100
      - MONOCHROME=false
    volumes:
      - /mnt/tank/general/scans/unprocessed:/scans
      - /var/brscans:/var/brscans
      - /var/log:/var/log
    network_mode: host
    restart: always
```

### Run the Docker container direct:

```bash
docker run -e NAME=Scanner -e MODEL=MFC-L2710DW -e IPADDRESS=192.168.1.41 -e DENSITY=150 -e COMPRESS=jpeg -e QUALITY=100 -e MONOCHROME=false -it --name=brscan-container -v /mnt/scans:/scans --net=host haitiangod/brother-brscan-skey
```

## Environment Variables

- _NAME: The name of your scanner._
- _MODEL: The model of your Brother device._
- _IPADDRESS: The IP address of your Brother device._
- _DENSITY: The density to use when converting scanned images to PDF (default is 150)._
- _COMPRESS: The compression method to use when converting scanned images to PDF (default is jpeg)._
- _QUALITY: The quality of the compression to use when converting scanned images to PDF (default is 100)._
- _MONOCHROME: Set to true if you want the scanned PDF to be monochrome, false otherwise (default is false)._

These environment variables allow you to customize the PDF conversion process to achieve the desired balance between image quality and file size.

## Supported Architectures

This Docker image utilizes Docker manifest for multi-platform awareness. More information on Docker manifest can be found [here](https://github.com/docker/distribution/blob/master/docs/spec/manifest-v2-2.md#manifest-list).

When pulling `haitiangod/brother-brscan-skey:latest`, Docker should automatically select the correct image for your architecture. However, you can also pull specific architecture images via tags.

The architectures supported by this image are:

| Architecture | Supported | Tag                   |
| :----------: | :-------: | --------------------- |
|    x86-64    |    ✅     | amd64-<version tag>   |
|    arm64     |    ✅     | arm64v8-<version tag> |
|    armhf     |    ❌     |                       |

Replace `<version tag>` with the tag of the version you wish to use.
