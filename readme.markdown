# Architect

Personal CI server

This system uses several different components,
some of which live in this repo,
and some which live in separate repos.

## Prerequisites

### Software

 -  The `architect-jenkins` Docker image (defined in this repository)
    must be built and pushed to Docker Hub
 -  The [`inflatable-wharf` Docker image](https://github.com/mrled/inflatable-wharf)
    must be built and pushed to Docker Hub
 -  Typically, I run this from [PSYOPS](https://github.com/mrled/psyops),
    but that is not a requirement

### Infrastructure

 -  You must have an IPSEC VPN
    (I use the excellent [Algo](https://github.com/trailofbits/algo)).
    See the config file for how to configure this.

 -  You must have a zone hosted in Route53

    That zone should resolve public hostnames to private IP addresses on your IPSEC VPN

    For instance, I have an `internal.micahrl.com.` zone with Route53,
    and [my Algo fork](https://github.com/mrled/algo)
    updates that zone automatically with VPN addresses when I deploy

 -  You must have credentials for an AWS IAM user,
    with credentials to update the Route53 zone,
    saved in `architect.cfg` (see that file for details).

    For instance, I create a group in when I
    [deploy my Route53 resource](https://github.com/mrled/psyops/blob/193ce3bd563dbd90d700583189c0242995b51676/dns/MicahrlDotCom.cfn.yaml#L132)
    with the correct permissions, then create a user from that group on the command line:

        # This group already existed, created in the aforelinked CloudFormation template
        # It already had the permission we need applied
        > inflw_group="MicahrlDotCom-InternalZoneUpdaterGroup-LV61HMYBWVXI"

        # This user does not already exist; we create it below
        > inflw_user="architect-inflwharf-zone-updater"

        > aws iam create-user --user-name "$inflw_user"
        {
            "User": {
                "Path": "/",
                "UserName": "architect-inflwharf-zone-updater",
                "UserId": "AIDAI5RDN56FJIAH3YWJM",
                "Arn": "arn:aws:iam::379474500957:user/architect-inflwharf-zone-updater",
                "CreateDate": "2018-02-24T22:45:57.280Z"
            }
        }

        > aws iam add-user-to-group --group-name "$inflw_group" --user-name "$inflw_user"

        > aws iam create-access-key --user-name "$inflw_user"
        {
            "AccessKey": {
                "UserName": "architect-inflwharf-zone-updater",
                "AccessKeyId": "<redacted>",
                "Status": "Active",
                "SecretAccessKey": "<redacted>",
                "CreateDate": "2018-02-24T22:50:15.312Z"
            }
        }

## Deploying

We use a normal Ansible vars file `architect.cfg` and vault file `architect.vault.cfg`.
We also use Ansible best practice of having all vault variables prepended with `vault_`,
and setting a non-prepended version in the vars file,
to make it clear where the variable in question is defined when grepping.

See the vars file for variables and comments on how to obtain them.

Now enter the virtual environment.
For the first run:

    python -m virtualenv venv.PSYOPS && source venv.PSYOPS/bin/activate && python -m pip install -U pip && python -m pip install -r requirements.txt

Subsequently, all that should be necessary is

    . venv.PSYOPS/bin/activate

Once you have these things configured, you can deploy with a simple command:

    ansible-playbook deploy.yaml --ask-vault-pass

## Creating new projects in Jenkins

-   Add a `Jenkinsfile` and a docker build file to whatever repo you're trying to create

    See the `mrled.github.io-source` repo for example.

-   Create new GitHub deploy key

    Name them after API client that will use them,
    the owner and name of the repo they belong to,
    and their permissions.

    For instance, a deploy key with the name
    `architect-jenkins_mrled_mrled.github.io_ro`
    is used by `architect-jenkins`,
    for a repo with owner `mrled` and name `mrled.github.io`,
    and it has read only (`ro`) access to the repository.

    I also always put the consumer in the comment.

    To create the key, I use a command like this:

        ssh-keygen -t ed25519 -a 100 -f ./architect-jenkins_mrled_mrled.github.io_ro -q -N "" -C "architect.internal.micahrl.com"

    Finally, don't forget to actually add the deploy key to GitHub

-   Configure a new project in Jenkins

    -   First upload the deploy key created previously to Jenkins

    -   Create a new pipeline project and configure repo and credential

    -   Set it to poll in the build triggers section

        This will poll once every 5 minutes at minute 0, 5, 10, etc

            */5 * * * *

        This will poll once every 5 minutes,
        but NOT exactly at the 0, 5, 10 etc marks -
        better to avoid GitHub API rate limiting

            H/5 * * * *

## Notes from initial Jenkins configuration

These notes aren't complete, but they'll help in case I need to start over.

- <https://wiki.jenkins.io/display/JENKINS/Docker+Plugin>
    - Docker URL: `unix:///var/run/docker.sock`

## Troubleshooting

### After a failed stack deployment

Rollback is disabled when deploying the CI stack,
but you may want to log into the console and delete it before another deployment anyway.

### Troubleshooting cfn-init

View userdata (from the instance itself)

    wget -q -O - http://169.254.169.254/latest/user-data

If the `cfn-init` command is failing,
comment out the `cfn-init` invocation in userdata,
deploy the stack,
run the command manually the same way it would be run by userdata,
and then check logs at `/var/log/cfn-*.log`.

You can also use the `cfn-get-metadata` command to see the `AWS::CloudFormation::Init` metadata from the template.
You can find the call to `cfn-init` in the CloudFormation template,
and then replace `cfn-init` with `cfn-get-metadata` to see the metadata exactly as `cfn-init` would.
For example:

    # The cfn-init call from userdata:
    cfn-init -v --stack "$stackname" --resource ArchitectInstance --region "$region"

    # Call cfn-get-metadata instead:
    cfn-get-metadata -v --stack "$stackname" --resource ArchitectInstance --region "$region"
