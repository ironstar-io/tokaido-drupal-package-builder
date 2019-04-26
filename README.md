Tokaido Drupal Package Builder
======

Tokaido provides a series of pre-built Drupal installations that can be involved with the `tok new` command.

This repo contains all the CI scripts are responsible for building and releasing these packages.

CircleCI will automatically create a new release of these packages every night.

## You can contribute templates
If you or your team would like to have a starting configuration for new Drupal projects you can submit a
PR to have that template added to this repo.

To add your template to this repo, create a new PR with the following additions/changes:

#### Add your template to `.circleci/config.yml`
We use a series of pre-defined commands in CircleCI that you can re-use in order to adapt your template.

For example, if you'd like to add a custom Drupal 8 config with custom Composer modules:
- Under `jobs:` add a new config block for your poject:
```
#########
# NAME: yourteam-drupal8-configuration
# DESCRIPTION: A custom Drupal 8 installation profile
# MAINTAINER: your-github-username
########
  build-yourteam-drupal8-configuration:
    <<: *tokaido72
    environment:
      PACKAGE_NAME: yourteam-drupal8-configuration
    steps:
    - checkout
    - wait-for-mysql
    - run: mkdir -p $PACKAGE_NAME
    - run: composer create-project drupal-composer/drupal-project:8.x-dev $PACKAGE_NAME --no-interaction
    - drush-site-install:
        package-name: $PACKAGE_NAME
    - persist_to_workspace:
        root: /tokaido/site
        paths:
          - yourteam-drupal8-configuration
  template-yourteam-drupal8-configuration:
    <<: *tokaido72
    steps:
      - attach_workspace:
          at: /tokaido/site
      - google-auth
      - upload-package:
          package-name: yourteam-drupal8-configuration
```
- Under `workflow:` add your project to the on-demand and weekly builds:
```
#########
# NAME: yourteam-drupal8-configuration
# DESCRIPTION: A custom Drupal 8 installation profile
# MAINTAINER: your-github-username
########
  ondemand-yourteam-drupal8-configuration:
    jobs:
      - build-yourteam-drupal8-configuration
      - template-yourteam-drupal8-configuration:
          requires:
            - build-yourteam-drupal8-configuration
  weekly-yourteam-drupal8-configuration:
    triggers:
      - schedule:
          cron: "0 18 * * 1"
          filters:
              branches:
                only:
                  - wip
                  - master
    jobs:
      - build-yourteam-drupal8-configuration
      - template-yourteam-drupal8-configuration:
          requires:
            - build-yourteam-drupal8-configuration
```

- Update `/templates.yaml` to add your package to the list of supported packages and also to specify any post-build steps you'd like the Tokaido CLI to run _inside_ the Tokaido environment, such as site-install, etc.
```
#########
# NAME: yourteam-drupal8-configuration
# DESCRIPTION: A custom Drupal 8 installation profile
# MAINTAINER: your-github-username
########
templates:
  yourteam-drupal8-configuration:
    package_url: https://downloads.tokaido.io/packages/yourteam-drupal8-configuration.tar.gz
    post_up_commands:
      - drush site-install -y
```

Note that if you can take any existing package and simply add a "templates" entry for it in order to customise the post_up_commands section, without the overhead of having to add another package that contains the same things.

Finally, you can not specify a package_url outside of downloads.tokaido.io. For security reasons, Tokaido will
only accept PRs that have been through this system.

#### Naming your package
The pattern "yourteam-drupal8-configuration" is important when you submit your PR, as we expect this system might get a fair few submissions before we end up maturing this into some kind of more advantage database.

As such, please name your package as follows:
- _yourteam_ is then name of your team or organisation. Ideally, this should be a github username.
- _drupal8_ is Drupal 8 if using Drupal 8, _drupal7_ for D7, etc.
- _configuration_ is your own reference for your config. You can make this whatever you want, but it should be a single word or words with no spaces, grammar, etc.
