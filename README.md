# Audible Unlock

This shell script unlocks all `.aax` files using rainbow tables from _rcrack_.

## Usage

### General

- Download your books from audible for offline access
- Go to this directory and checkout this repository including submodules

### On Windows
 
- Download and install [chocolatey](https://chocolatey.org/)
- Install _cygwin_ and _ffmpeg_ as admin
  ```
  choco install ffmpeg cygwin
  ```
- Open _cygwin_ shell in the audible download folder
- Run `bash audible-unlock.sh`

### On Linux

- Install _ffmpeg_ with a package manager of your choice
- Go to your audible download folder
- Run `bash audible-unlock.sh`

### Docker

```shell
docker run -it --volume=/Users/mike.reiche//Downloads:/data ubuntu /bin/bash
```
```shell
apt-get update
apt-get install ffmpeg libavcodec-extra gawk wine
```
