# Active Directory Domain Creation and Replication

A **_domain infrastructure_** setup for the `khangvum.lab` forest, which involves promoting `KVM-DC01` as the **_primary domain controller_** (**_PDC_**), joining `KVM-DC02` as a **_secondary domain controller_**, and ensuring **_multi-master replication_** across the environment.

## Domain Controller Roles

Domain Controller   |Role
:------------------:|----
`KVM-DC01`          |Hold all the **_Flexible Single Master Operations_** (**_FSMO_**) **roles_** and act as the **_primary NTP time source_**
`KVM-DC02`          |Provide **_high availability_** (**_HA_**) and **_fault tolerance_** if the PDC is offline