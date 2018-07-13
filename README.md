// this is depracated
// the whole project has been merged into [adshares/dockerization](https://github.com/adshares/dockerization)


# README @ adshares/dockerization-framework

Little bash framework to help automate projects dockerization

## Technical information

  * Requires Host NGINX proxy
    - or Apache but no config in repo, make a pull request if you have one
  * Requires Docker version 1.13.1 - dev/tested on build 092cba3
  * Requires docker-compose version 1.8.0
  * Requires GNU Bash - dev/tested on 4.3.48(1)-release
  * Developed/Tested on Bodhi Linux 16.04 (based on Ubuntu 16.04)

## How to use

### Dockerization repo

 Create a separate repository for your projects dockerization. Check [example](your-repo-example)

### Framework installation

 Once you have created your repo based on our example, run

```
 $ ./framework-install.sh
```

### Development example setup

Please check contents of [development](your-repo-example/development) directory

### Testing example setup

Please check contents of [testing](your-repo-example/testing) directory

### Usage

```
$ cd development
$ ./console.sh help

Usage: console.sh COMMAND ARGUMENTS OPTIONS

Available commands (order of usage):

 * [help] - displays this output
 * [list] - list available PROJECTS

 * [link] (PROJECT-NAME) (PATH) - link your project with your workspace repository dir
 * [proxy] (PROJECT-NAME) (PATH) - link your project host NGINX proxy configuration to your sites-enabled (requires sudo access and NGINX)

 * [build] (PROJECT-NAME)
 * [rebuild] (PROJECT-NAME)
 * [up] (PROJECT-NAME)
 * [down] (PROJECT-NAME)
 * [start] (PROJECT-NAME)
 * [stop] (PROJECT-NAME)

```

(to be continued)


## Technical Support

  * Pull requests only

## Credits

  * [Yodahack](https://github.com/yodahack)

## License

  * [MIT](LICENSE)
