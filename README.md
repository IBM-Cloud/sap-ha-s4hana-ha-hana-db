# Automation scripts for HA S/4HANA SAP-COE project

## Steps to reproduce:

For initializing terraform:

```shell
terraform init
```

For planning phase:

```shell
terraform plan --out plan1
# you will be asked for the following sensitive variables: 'ibmcloud_api_key'  and  'sap_main_password'.
```

For apply phase:

```shell
terraform apply
```

For destroy:

```shell
terraform destroy
# you will be asked for the following sensitive variables as a destroy confirmation phase:
'ibmcloud_api_key'  and  'sap_main_password'.
```


### Related links:

- [See how to create a BASTION/STORAGE VSI for SAP in IBM Schematics](https://github.ibm.com/workload-eng-services/SAP/tree/dev/ibm-schematics/sapbastionsetup-sch)

