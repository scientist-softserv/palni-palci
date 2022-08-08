# PALCI-PALNI

---

## Table of Contents

- [Prerequisites](#prerequisites)
  - [Install Docker](#install-docker)
  - [Install Dory](#install-dory)
- [Running the stack](#running-the-stack)
  - [Getting Started](#getting-started)
  - [Metadata Profiles](#metadata-profiles)
  - [Troubleshooting](#troubleshooting)

---

## Prerequisites
### Install Docker
- Download [Docker Desktop](https://www.docker.com/products/docker-desktop) and log in.

### Install Dory
On OS X or Linux we recommend running [Dory](https://github.com/FreedomBen/dory). It acts as a proxy allowing you to access domains locally such as app.test or tenant.app.test, making multitenant development more straightforward and prevents the need to bind ports locally. Be sure to [adjust your ~/.dory.yml file to support the .test tld](https://github.com/FreedomBen/dory#config-file).

```bash
gem install dory
```

_You can still run in development via docker with out Dory, but to do so please uncomment the ports section in docker-compose.yml_

## Running the stack
### Getting Started
1. Clone the repository and cd into the folder

2. Install and run dory
```bash
$ gem install dory
$ dory up
```

3. Install Stack Car
```bash
$ gem install stack_car
```

4. If this is the first time building the application or if any of the dependencies changed, please build with:
```bash
$ sc build
```

5. After building the application, bring the container up with:
```bash
$ sc up
```

6. Once the application is up and running, navigate to [pals.hyku.test](https://pals.hyku.test)in the browser and log in with the following credentials in [1Pass](https://start.1password.com/open/i?a=LTLZ652TT5H5FHMYMASSH7PIXM&v=huuakin4bu4xanlhktv42qheam&i=rwoxygppajcurfqdyuebfxmb34&h=scientist.1password.com)
  - When loading a tenant you may need to login through the browser: un: pals pw: pals

7. Seed a superadmin
```bash
$ docker compose exec web bash
$ bundle exec rake hyku:roles:seed_superadmin
```

Login credential for the superadmin: 

- admin@example.com
- testing123

Once you are logged in as a superadmin, you can create an account/tenant in the UI by selecting Accounts from the menu bar

8. #### Tests in Docker

The full spec suite can be run in docker locally. There are several ways to do this, but one way is to run the following:

```bash
$ docker compose exec web bash
# To run a specific test
$ bundle exec rspec spec/PATH_TO_FILE
```
** We recommend committing .env to your repo with good defaults. .env.development, .env.production etc can be used for local overrides and should not be in the repo.**

### Metadata Profiles
In order to create or import any models, a metadata profile must be uploaded.
  - Dashboard >> Metadata Profiles >> Import Profile

### Troubleshooting
- Is dory up? Check with a `docker ps` do you see the dory container up and running? If not run `dory up`

- Did you [adjust your ~/.dory.yml file to support the .test tld](https://github.com/FreedomBen/dory#config-file)?

- Did you checkout main and give it a `git pull`?
  - In that `git pull` were there any updates to the config files? Do you need to rebuild with `sc build`?
  - If that does not work, your last ditch effort is to do a no-cache build (but it takes forever so talk to the Project Manager at this point to see what you should do with your time, rebuild or get help).
    ```bash
    # drop all containers and volumes
    $ docker-compose down -v
    $ docker-compose build --no-cache
    $ sc up
    ```
    
