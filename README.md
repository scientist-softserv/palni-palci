Docker development setup
1. Install and run Docker.app

2. Install and run dory

$ gem install dory
$ dory up

Run the dory setup to allow for using the .test domain
http://playbook-staging.notch8.com/en/dev/environment/run-dory-without-password

3. Build Docker Image

$ docker compose build

4. Start up server

$ docker compose up

5. Seed a superadmin

$ docker compose exec web bash
$ bundle exec rake hyku:roles:seed_superadmin

Login credential for the superadmin: 

- admin@example.com
- testing123

Once you are logged in as a superadmin, you can create an account/tenant in the UI by selecting Accounts from the menu bar

6. #### Tests in Docker

The full spec suite can be run in docker locally. There are several ways to do this, but one way is to run the following:

```bash
$ docker compose exec web bash
# To run a specific test
$ bundle exec rspec spec/PATH_TO_FILE
```
** We recommend committing .env to your repo with good defaults. .env.development, .env.production etc can be used for local overrides and should not be in the repo.**
