# Simple R Version Management: renv

renv lets you easily switch between multiple versions of R. It's
simple, unobtrusive, and follows the UNIX tradition of single-purpose
tools that do one thing well.

This project was forked from [pyenv](https://github.com/pyenv/pyenv), and modified for R.


### renv _does..._

* Let you **change the global R version** on a per-user basis.
* Provide support for **per-project R versions**.
* Allow you to **override the R version** with an environment
  variable.
* Search commands from **multiple versions of R at a time**.


### renv _does not..._

* **Depend on R itself.** renv was made from pure shell scripts.
    There is no bootstrap problem of R.
* **Need to be loaded into your shell.** Instead, renv's shim
    approach works by adding a directory to your `$PATH`.
* **Manage virtualenv.** Of course, you can create [virtualenv](https://pypi.python.org/pypi/virtualenv)
    yourself.


----


## How It Works

At a high level, renv intercepts R commands using shim
executables injected into your `PATH`, determines which R version
has been specified by your application, and passes your commands along
to the correct R installation.

### Understanding PATH

When you run a command like `R`, your operating system
searches through a list of directories to find an executable file with
that name. This list of directories lives in an environment variable
called `PATH`, with each directory in the list separated by a colon:

    /usr/local/bin:/usr/bin:/bin

Directories in `PATH` are searched from left to right, so a matching
executable in a directory at the beginning of the list takes
precedence over another one at the end. In this example, the
`/usr/local/bin` directory will be searched first, then `/usr/bin`,
then `/bin`.

### Understanding Shims

renv works by inserting a directory of _shims_ at the front of your
`PATH`:

    $(renv root)/shims:/usr/local/bin:/usr/bin:/bin

Through a process called _rehashing_, renv maintains shims in that
directory to match every R command across every installed version
of R.

Shims are lightweight executables that simply pass your command along
to renv. So with renv installed, when you run, say, `R`, your
operating system will do the following:

* Search your `PATH` for an executable file named `R`
* Find the renv shim named `R` at the beginning of your `PATH`
* Run the shim named `R`, which in turn passes the command along to
  renv

### Choosing the R Version

When you execute a shim, renv determines which R version to use by
reading it from the following sources, in this order:

1. The `RENV_VERSION` environment variable (if specified). You can use
   the [`renv shell`](https://github.com/jcrodriguez1989/renv-installer/blob/master/COMMANDS.md#renv-shell) command to set this environment
   variable in your current shell session.

2. The application-specific `.R-version` file in the current
   directory (if present). You can modify the current directory's
   `.R-version` file with the [`renv local`](https://github.com/jcrodriguez1989/renv-installer/blob/master/COMMANDS.md#renv-local)
   command.

3. The first `.R-version` file found (if any) by searching each parent
   directory, until reaching the root of your filesystem.

4. The global `$(renv root)/version` file. You can modify this file using
   the [`renv global`](https://github.com/jcrodriguez1989/renv-installer/blob/master/COMMANDS.md#renv-global) command. If the global version
   file is not present, renv assumes you want to use the "system"
   R. (In other words, whatever version would run if renv weren't in your
   `PATH`.)

### Locating the R Installation

Once renv has determined which version of R your application has
specified, it passes the command along to the corresponding R
installation.

Each R version is installed into its own directory under
`$(renv root)/versions`.

For example, you might have these versions installed:

* `$(renv root)/versions/3.0.0/`
* `$(renv root)/versions/3.6.3/`
* `$(renv root)/versions/4.0.0/`

As far as renv is concerned, version names are simply the directories in
`$(renv root)/versions`.


----


## Installation

### Basic GitHub Checkout

This will get you going with the latest version of renv and make it
easy to fork and contribute any changes back upstream.

1. **Check out renv where you want it installed.**
   A good place to choose is `$HOME/.renv` (but you can install it somewhere else).

        $ git clone https://github.com/jcrodriguez1989/renv-installer.git ~/.renv


2. **Define environment variable `RENV_ROOT`** to point to the path where
   renv repo is cloned and add `$RENV_ROOT/bin` to your `$PATH` for access
   to the `renv` command-line utility.

   - For **bash**:
     ~~~ bash
     $ echo 'export RENV_ROOT="$HOME/.renv"' >> ~/.bash_profile
     $ echo 'export PATH="$RENV_ROOT/bin:$PATH"' >> ~/.bash_profile
     ~~~

   - For **Ubuntu Desktop**:
     ~~~ bash
     $ echo 'export RENV_ROOT="$HOME/.renv"' >> ~/.bashrc
     $ echo 'export PATH="$RENV_ROOT/bin:$PATH"' >> ~/.bashrc
     ~~~

   - For **Zsh**:
     ~~~ zsh
     $ echo 'export RENV_ROOT="$HOME/.renv"' >> ~/.zshrc
     $ echo 'export PATH="$RENV_ROOT/bin:$PATH"' >> ~/.zshrc
     ~~~

   - For **Fish shell**:
     ~~~ fish
     $ set -Ux RENV_ROOT $HOME/.renv
     $ set -Ux fish_user_paths $RENV_ROOT/bin $fish_user_paths
     ~~~

   - **Proxy note**: If you use a proxy, export `http_proxy` and `HTTPS_PROXY` too.

3. **Add `renv init` to your shell** to enable shims and autocompletion.
   Please make sure `eval "$(renv init -)"` is placed toward the end of the shell
   configuration file since it manipulates `PATH` during the initialization.
    ```sh
    $ echo -e 'if command -v renv 1>/dev/null 2>&1; then\n  eval "$(renv init -)"\nfi' >> ~/.bash_profile
    ```
    - **Zsh note**: Modify your `~/.zshrc` file instead of `~/.bash_profile`.
    - **fish note**: Use `renv init - | source` instead of `eval (renv init -)`.
    - **Ubuntu and Fedora note**: Modify your `~/.bashrc` file instead of `~/.bash_profile`.

    **General warning**: There are some systems where the `BASH_ENV` variable is configured
    to point to `.bashrc`. On such systems you should almost certainly put the above mentioned line
    `eval "$(renv init -)"` into `.bash_profile`, and **not** into `.bashrc`. Otherwise you
    may observe strange behaviour, such as `renv` getting into an infinite loop.
    See [#264](https://github.com/pyenv/pyenv/issues/264) for details.

4. **Restart your shell so the path changes take effect.**
   You can now begin using renv.
    ```sh
    $ exec "$SHELL"
    ```

5. **Install R build dependencies** before attempting to install a new R version.  The
   [renv wiki](https://github.com/pyenv/pyenv/wiki) provides suggested installation packages
   and commands for various operating systems.

6. **Install R versions into `$(renv root)/versions`.**
   For example, to download and install R 3.0.0, run:
    ```sh
    $ renv install 3.0.0
    ```
   **NOTE:** If you need to pass configure option to build, please use
   ```CONFIGURE_OPTS``` environment variable.

   **NOTE:** If you want to use proxy to download, please use `http_proxy` and `https_proxy`
   environment variable.

   **NOTE:** If you are having trouble installing an R version,
   please visit the wiki page about
   [Common Build Problems](https://github.com/pyenv/pyenv/wiki/Common-build-problems)


#### Upgrading

If you've installed renv using the instructions above, you can
upgrade your installation at any time using git.

To upgrade to the latest development version of renv, use `git pull`:

```sh
$ cd $(renv root)
$ git pull
```

### Uninstalling renv

The simplicity of renv makes it easy to temporarily disable it, or
uninstall from the system.

1. To **disable** renv managing your R versions, simply remove the
  `renv init` line from your shell startup configuration. This will
  remove renv shims directory from PATH, and future invocations like
  `R` will execute the system R version, as before renv.

  `renv` will still be accessible on the command line, but your R
  apps won't be affected by version switching.

2. To completely **uninstall** renv, perform step (1) and then remove
   its root directory. This will **delete all R versions** that were
   installed under `` $(renv root)/versions/ `` directory:
    ```sh
    rm -rf $(renv root)
    ```

#### Post-installation

Then follow the rest of the post-installation steps under [Basic GitHub Checkout](https://github.com/pyenv/pyenv#basic-github-checkout) above, starting with #3 ("Add `renv init` to your shell to enable shims and autocompletion").

### Advanced Configuration

Skip this section unless you must know what every line in your shell
profile is doing.

`renv init` is the only command that crosses the line of loading
extra commands into your shell. Coming from rvm, some of you might be
opposed to this idea. Here's what `renv init` actually does:

1. **Sets up your shims path.** This is the only requirement for renv to
   function properly. You can do this by hand by prepending
   `$(renv root)/shims` to your `$PATH`.

2. **Installs autocompletion.** This is entirely optional but pretty
   useful. Sourcing `$(renv root)/completions/renv.bash` will set that
   up. There is also a `$(renv root)/completions/renv.zsh` for Zsh
   users.

3. **Rehashes shims.** From time to time you'll need to rebuild your
   shim files. Doing this on init makes sure everything is up to
   date. You can always run `renv rehash` manually.

4. **Installs the sh dispatcher.** This bit is also optional, but allows
   renv and plugins to change variables in your current shell, making
   commands like `renv shell` possible. The sh dispatcher doesn't do
   anything crazy like override `cd` or hack your shell prompt, but if
   for some reason you need `renv` to be a real script rather than a
   shell function, you can safely skip it.

To see exactly what happens under the hood for yourself, run `renv init -`.


### Uninstalling R Versions

As time goes on, you will accumulate R versions in your
`$(renv root)/versions` directory.

To remove old R versions, `renv uninstall` command to automate
the removal process.

Alternatively, simply `rm -rf` the directory of the version you want
to remove. You can find the directory of a particular R version
with the `renv prefix` command, e.g. `renv prefix 3.0.0`.


----


## Command Reference

See [COMMANDS.md](COMMANDS.md).


----

## Environment variables

You can affect how renv operates with the following settings:

name | default | description
-----|---------|------------
`RENV_VERSION` | | Specifies the R version to be used.<br>Also see [`renv shell`](https://github.com/jcrodriguez1989/renv-installer/blob/master/COMMANDS.md#renv-shell)
`RENV_ROOT` | `~/.renv` | Defines the directory under which R versions and shims reside.<br>Also see `renv root`
`RENV_DEBUG` | | Outputs debug information.<br>Also as: `renv --debug <subcommand>`
`RENV_HOOK_PATH` | [_see wiki_][hooks] | Colon-separated list of paths searched for renv hooks.
`RENV_DIR` | `$PWD` | Directory to start searching for `.R-version` files.



## Development

The renv source code is [hosted on
GitHub](https://github.com/jcrodriguez1989/renv-installer).  It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/jcrodriguez1989/renv-installer/issues).


  [hooks]: https://github.com/pyenv/pyenv/wiki/Authoring-plugins#renv-hooks

### License

[The MIT License](LICENSE)
