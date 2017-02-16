# Docker AMP Stack

Docker based Apache, MariaDB, PHP stack.

Intended for testing PHP / MySQL applications in localhost environment.


## Features

 * Can easily create clean environment for testing.

 * Support testing multiple PHP version easily. Just change the localhost domain
   and you may see how your applicaiton runs / crash :-)

 * Simple command to import your existing database dump. Also support working
   interactively through mysql CLI.

 * Stores database in data volume. Starting and stopping MariaDB container
   won't lost any data.

 * Apache logs mount to your volumne.

 * You may customize Apache config easily.


## Documentation

Please read the [Documentation file](DOCS.md) in this repository for
installation and usage instructions.


## License

This repository is license under the [MIT License](https://opensource.org/licenses/MIT).
You may obtain a copy of the license is in [LICENSE.md](LICENSE.md).
