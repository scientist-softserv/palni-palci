# PALCI-PALNI

---

## Table of Contents

- [Prerequisites](#prerequisites)
  - [Install Docker](#install-docker)
  - [Install Dory](#install-dory)
- [Running the stack](#running-the-stack)
  - [Getting Started](#getting-started)
- [Tests in Docker](#tests-in-docker)
  - [Feature Specs](#feature-specs)
- [Troubleshooting](#troubleshooting)
  - [Universal Viewer in Development](#universal-viewer-in-development)
- [Working with Translations](#working-with-translations)
- [Switching accounts](#switching-accounts)
- [Overrides to Dependencies](#overrides-to-dependencies)
  - [Overrides using class_eval](#overrides-using-class_eval)
  - [Overrides using the decorator pattern](#overrides-using-the-decorator-pattern)
- [Groups, Roles, and Auth](#groups-roles-and-auth)
- [Importing](#importing)
  - [enable Bulkrax](#enable-bulkrax)
  - [from CSV](#from-csv)
- [Workflows](#workflows)

---

## Prerequisites

### Install Docker

- Download [Docker Desktop](https://www.docker.com/products/docker-desktop) and log in.

### Install Dory

On OS X or Linux we recommend running [Dory](https://github.com/FreedomBen/dory). It acts as a proxy allowing you to access domains locally such as app.test or tenant.app.test, making multitenant development more straightforward and prevents the need to bind ports locally. Be sure to [adjust your ~/.dory.yml file to support the .test tld](https://github.com/FreedomBen/dory#config-file).

Dory configuration and setup can be found in the playbook at <http://playbook-staging.notch8.com/en/dev/environment/run-dory-without-password>

```bash
gem install dory
```

_You can still run in development via docker with out Dory, but to do so please uncomment the ports section in docker-compose.yml_

## Running the stack

### Getting Started

1. Clone the repository and cd into the folder

2. Install and run dory

```bash
gem install dory
dory up
```

3. Install Stack Car

```bash
gem install stack_car
```
_Or use the equivalent docker compose commands commented below_

4. If this is the first time building the application or if any of the dependencies changed, please build with:

```bash
sc build # `docker compose build (web)`
```

5. After building the application, bring the container up with:

```bash
sc up # `docker compose up (web)`
```

6. Once that starts (you'll see the line `Passenger core running in multi-application mode.` to indicate a successful boot), navigate to [hyku.test](https://hyku.test)in the browser.

7. Seed a superadmin

```bash
sc sh # `docker compose exec web sh`
bundle exec rake hyku:roles:seed_superadmin
```

Login credential for the superadmin:
- admin@example.com
- testing123

Once you are logged in as a superadmin, you can create an account/tenant in the UI by selecting Accounts from the menu bar
_If logging in as the superadmin redirects you to the home page, clear the cookies for hyku.test and try again._

- When loading a tenant you may need to login through the browser: un: pals pw: pals

## Tests in Docker

The full spec suite can be run in docker locally. There are several ways to do this, but one way is to run the following:

```bash
$ sc sh # `docker compose exec web sh`
# To run a specific test
$ bundle exec rspec spec/PATH_TO_FILE
```

### Feature Specs

Feature specs can be viewed in the Screen Sharing app on the Mac.
When you launch the Screen Sharing app you will need to connect to your IP address and port 5959:

```

Connect To: vnc://127.0.0.1:5959
Password: secret
```

The server must be running when you connect.

## Troubleshooting

- Is dory up? Check with a `docker ps` do you see the dory container up and running? If not run `dory up`

- Did you [adjust your ~/.dory.yml file to support the .test tld](https://github.com/FreedomBen/dory#config-file)?

- Did you checkout main and give it a `git pull`?
  - In that `git pull` were there any updates to the config files? Do you need to rebuild with `sc build`?
  - If that does not work, your last ditch effort is to do a no-cache build (but it takes forever so talk to the Project Manager at this point to see what you should do with your time, rebuild or get help).

    ```bash
    # drop all containers and volumes
    $ docker compose down -v
    $ docker compose build --no-cache
    $ sc up
    ```

### Universal Viewer in Development

When running Hyrax v2.9.0, there is an issue where IIIF has mixed content error when running with SSL enabled.

See Samvera Slack thread <https://samvera.slack.com/archives/C0F9JQJDQ/p1596718417351200?thread_ts=1596717896.350700&cid=C0F9JQJDQ>

To allow the Universal Viewer to run without SSL enabled, comment these in the url building lambdas in the Hyrax initializer.

In config.hyrax.rb in the config.iiif_image_url_builder lambdas, comment these lines:

  ```ruby
  # base_url = base_url.sub(/\Ahttp:/, 'https:')
  ```

  and

  ```ruby
  # uri.sub(/\Ahttp:/, 'https:')
  ```

Once the application moves to Hyrax 3.0 or above, these lines should be removed.

## Working with Translations

You can log all of the I18n lookups to the Rails logger by setting the I18N_DEBUG environment variable to true. This will add a lot of chatter to the Rails logger (but can be very helpful to zero in on what I18n key you should or could use).

```console
I18N_DEBUG=true bin/rails server
```

## Switching accounts

There are three recommend ways to switch your current session from one account to another by using:

```ruby
switch!(Account.first)
# or
switch!('my.site.com')
# or
switch!('myaccount')
```

## Overrides to Dependencies

Overrides to Hyku, Hyrax, and other dependencies can be found throughout the repository. These are denoted with `OVERRIDE` code comments.

When making an override to a dependency, please add an `OVERRIDE: <library><version>` comment explaining what changed and why.

**Note**: legacy overrides may not have an all-caps `OVERRIDE` comment (e.g. `Override`), or the libray or version number.

### Overrides using class_eval

Some classes from dependencies have had parts of them overwritten using the `#class_eval` method. These overrides live where the file originally lived in its dependency
(e.g. the override for [hyrax/app/services/hyrax/collections/permissions_create_service.rb](https://github.com/samvera/hyrax/blob/v2.9.0/app/services/hyrax/collections/permissions_create_service.rb)
lives in [app/services/hyrax/collections/permissions_create_service.rb](app/services/hyrax/collections/permissions_create_service.rb)).

The reasons these overrides have been written the way they have are as follows:

1. Only bring over code that needs to be touched / bring over less unnecessary code
1. Easier to find what has been overwritten
1. Using `#class_eval` in combination with `#require_dependency` in the original file's file path allows Rails autoload to work properly, ensuring the
original file from the dependency is loaded and then the override is loaded on top of that
1. Future dependency upgrades will be easier; reconciling different versions of one or two methods within a class is much easier than an entire file

### Overrides using the decorator pattern

Overrides using the decorator pattern can be found in this app. For more information on this pattern, see the playbook article:
<http://playbook-staging.notch8.com/en/dev/ruby/decorators-and-class-eval>

## Groups, Roles, and Auth

See [GROUPS_WITH_ROLES.md](GROUPS_WITH_ROLES.md)

## Importing

### enable Bulkrax

Set bulkrax -> enabled to true in settings (via file or env variable)

(in a `docker-compose exec web bash` if you're doing docker otherwise in your terminal)

```bash
bundle exec rails db:migrate
```

**NOTE:** Some Bulkrax overrides are located in [bulkrax_overrides.rb](config/initializers/bulkrax_overrides.rb). Others are located throughout the repo labeled with "override" comments.

### from CSV

```bash
./bin/import_from_csv localhost spec/fixtures/csv/gse_metadata.csv ../hyku-objects
```

## Workflows

To set the default workflow, update the name of the default workflow in config/initializers/hyrax.rb

```bash
config.default_active_workflow_name = 'new_workflow_name'
```

After setting the new name, run the 'workflow_setup' rake task. This task will add the new workflow to admin sets in each tenant.


Multi-tenant mode:

```bash
rake tenantize:task[workflow:setup]
```
