# mattermost-update

[![License][mit-badge]][mit-url]

> Simple script for comfortable update of Mattermost

## Install

```bash
cd /usr/local/bin
wget https://raw.githubusercontent.com/icelander/mattermost-update/master/mmupdate.sh
chmod a+x mmupdate.sh
```

In the first few lines of the script you possibly have to change the variable `MM_PATH` (default is `/opt/mattermost).

This script utilizes [jq](https://stedolan.github.io/jq/), wget and sudo, so these need to be installed as prerequisite.

## Usage

Copy the URL of the latest Mattermost tarball from http://about.mattermost.com/download/ and call `mmupdate.sh` with the path of you Mattermost installation and the tarball url as parameters.

Example:
```bash
sudo mmupdate.sh /opt/mattermost https://releases.mattermost.com/5.1.0/mattermost-5.1.0-linux-amd64.tar.gz
```


## To Do

* Backup of MySQL Database (until now only Postgres is implemented)
* More testing
* Nicer console output (e.g. colored unicode checkmarks)?
* Fully automated update: another script that checks the Mattermost webpage for updates and calls mmupdate.sh
* Omit data dir backup if FileSettings.DriverName != "local", or with --no-data flag

## Contributing

Pull Requests Welcome! :-)


## License

MIT © [Paul Rothrock](https://github.com/icelander)

[mit-badge]: https://img.shields.io/badge/License-MIT-blue.svg?style=flat
[mit-url]: LICENSE
