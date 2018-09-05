# Bugs and to do list

- Add Mitogen support
    - I think I'll need to use the 2.7 release candidate for Docker Swarm support
    - Mitogen only supports up to Ansible 2.5 for now
    - Might have to wait on this a bit
- Update readme to indicate this is no longer just Architect, it's all my infrastructure (except Algo)
- Rename the repo
- Consider using delegation to deploy the base Docker CFN server + ansible tasks on top: https://docs.ansible.com/ansible/2.6/user_guide/playbooks_delegation.html
- Make some master list of all variables used in each role and document them somehow
- Perform the `Add new instance to host group` post_task from within the cfn_dockerhost role.