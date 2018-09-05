# Plan for this

Dealing with database stuff:

- Dockerfile gets as far along in building pleroma as it can
- Dockerfile entrypoint starts are ROOT
- Root has creds to talk to the PSQL server as a db superuser
- Root connects and configures DB with stuff that requires db superuser privs (see pleroma/lib/mix/tasks/sample_psql.eex)
    https://git.pleroma.social/pleroma/pleroma/blob/develop/lib/mix/tasks/sample_psql.eex
    - might have to rewrite the sample_psql file to handle errors? unclear: https://stackoverflow.com/questions/18389124/simulate-create-database-if-not-exists-for-postgresql#36591842
- Root drops privs to pleroma user
- Pleroma user runs `mix phx.serve` or whatever

Dealing with configs

- Configs are mounted as Docker volumes or Docker Swarm secrets
- Configs are mounted before the container is started
- The compilation step - if the configs are even compiled?? - happens after
    - it must happen during `mix phx.serve`, right ?
    - or everyone is confused about how the configuration works
- Can probably always use the `prod` value for `MIX_ENV` and just have the prod config be the one that is mounted as volume / swarm secret
- `mix` management tasks could be done by just a `docker exec` into the container directly?
    https://git.pleroma.social/pleroma/pleroma/tree/develop/lib/mix/tasks

See also

- this guy might be very confused: https://github.com/angristan/docker-pleroma
- debian instructions (no mention of "compiling" the config?): https://git.pleroma.social/pleroma/pleroma/wikis/Installing%20on%20Debian%20based%20distributions
- the gitlab-ci config before_script doesn't seem to do any configuration "compilation"? https://git.pleroma.social/pleroma/pleroma/blob/develop/.gitlab-ci.yml
- also note what the gitlab-ci config before_script does, maybe we want to just replicate that? although obviously its doing `mix test` not `mix phx.serve` so maybe not
- some official notes about configuration: https://git.pleroma.social/pleroma/pleroma/blob/develop/CONFIGURATION.md
