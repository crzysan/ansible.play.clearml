# ansible.play.clearml

## prerequisites

You need to install the following packages.

yum install ansible wget -y

## vault

In inventory/group_vars/all/vault.yml you need to add the following variables.


```yaml
---
public_key: ""
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
clearml_secret_key: sarampass

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
