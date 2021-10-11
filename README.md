# Deploy Clearml server and agent on AWS

This playbook will create aws resources that will be used to deploy clearml server and agents


## prerequisites

You need to have ansible installed and configured on your machine.

## vault

In inventory/group_vars/all/vault.yml you need to add the following variables.
- To get public_key copy content of .ssh/id_rsa.pub
- To get aws access key: https://docs.aws.amazon.com/powershell/latest/userguide/pstools-appendix-sign-up.html
- clearml keys will be created after clearml server has been deployed or use the user username and pass (unencrypted)
- clearml users must be manually added however pass must be encrypted in the file
```yaml
---
public_key: "ssh-rsa XXXXXXXXXXXXXXXXXXX"
aws_access_key_id: "AXXXXXXXXXXXXXXXXX"
aws_secret_access_key: "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

clearml_users:
  - username: saram
    pass: XXXXXXXXXXXXXXXXXXXX
    fullname: "Sara Macoy"
  - username: jackyl
    pass: XXXXXXXXXXXXXXXXXXXX
    fullname: "Jacky Li"
  - username: medinaj
    pass: XXXXXXXXXXXXXXXXXXXX
    fullname: "Medina Jackson"

clearml_access_key: saram
clearml_secret_key: pass123

```
Note: to generate bcrypt clearml user password use python command
```bash
python3 -c 'import bcrypt,base64; print(base64.b64encode(bcrypt.hashpw("pass123".encode(), bcrypt.gensalt())))'
```

Add vault password to .vault-pass file
```bash
echo secretpassword > .vault-pass
chmod 400 .vault-pass
```

encrypt inventory/group_vars/all/vault.yml with
```bash
ansible-vault encrypt inventory/group_vars/all/vault.yml
```

After this you can run your playbook as follows.

```bash
ansible-playbook playbooks/create-aws-instances.yml
ansible-playbook playbooks/install-server.yaml
ansible-playbook playbooks/install-agent.yaml
```
Note: 
Update variable aws_instance_state to present in inventory/group_vars/all/all.yml to create resources
If you want to destroy your resources in aws update variable aws_instance_state to absent     
