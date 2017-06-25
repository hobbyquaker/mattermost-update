# mattermost-update

[![License][mit-badge]][mit-url]

> Simple script for comfortable update of Mattermost


## Install

```bash
cd /usr/local/bin
wget https://raw.githubusercontent.com/hobbyquaker/mattermost-update/master/mmupdate.sh
chmod a+x mmupdate.sh
```


## Usage

Get the URL of the latest Mattermost tarball from http://about.mattermost.com/download/ and call mmupdate.sh with this
url as parameter.

Example:
```bash
mmupdate.sh https://releases.mattermost.com/3.10.0/mattermost-3.10.0-linux-amd64.tar.gz
```


## Todo

* Backup of MySQL Database (until now only Postgres is implemented)
* More testing
* Nicer Console Output (e.g. colored unicode checkmarks)?


## Contributing

Pull Requests Welcome! :-)


## License

MIT © [Sebastian Raff](https://github.com/hobbyquaker)


[mit-badge]: https://img.shields.io/badge/License-MIT-blue.svg?style=flat
[mit-url]: LICENSE
