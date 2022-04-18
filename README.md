# Creating a Multi-Tenant Web API using App Configuration Service and Key Vault

To create web applications and APIs that are multi-tenant, the application/API code needs to be multitenancy-aware. Tthe applications/APIs must be able to determine the tenenat the request belongs to and ensure the appropriate database are used for transactions belonging to a particular tenant. This is especially true when using the [horizontally partitioned deployment](https://docs.microsoft.com/en-us/azure/architecture/guide/multitenant/considerations/tenancy-models#horizontally-partitioned-deployments) multi-tenancy model, as shown below.

![Horizontally Partitioned Deployment Model](media/s1.png)

In this model, the data is isolated into database per tenant and the front-end application and APIs are shared. As such the [recommended approach](https://docs.microsoft.com/en-us/azure/azure-sql/database/saas-tenancy-app-design-patterns#d-multi-tenant-app-with-database-per-tenant) is to use a Catalog to store mappings of tenants to databases, as shown below.

![Use of Catalog to store mappings of tenants to databases](media/s2.png)

The applications/APIs consult the Catalog, get the tenant specific database connection information and complete the operations as necessary using the appropriate tenant database. 

## Proposed Architecture

To create a multi-tenant application or API, the below architecture is propsed.

![Multi-Tenant API using App Config Service and Key Vault](media/MultitenantAPI.png)

### Components

1. [App Service](https://docs.microsoft.com/en-us/azure/app-service/overview): This hosts the multi-tenant application or API code.

1. [App Configuration Service](https://docs.microsoft.com/en-us/azure/azure-app-configuration/overview): This contains all tenant configurations arranged in grouping by tenant identifier. See below for how to setup Keys.

1. [Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/general/overview): This stores all sensitive tenant information such as database connection information and other credentials.

### Setup App Configuration Keys

Use Key prefixes to create groupings of configurations corresponding to each tenant. Name the settings in the format "\<TenantName\>:\<Grouping\>:\<Key-Name\>".

For example, given the tenants "Alpha, Bravo, Charlie", you can setup the "CustomerName" setting as below:

```bash
"Alpha:Settings:CustomerName"

"Bravo:Settings:CustomerName"

"Charlie:Settings:CustomerName"

```

And to setup the "OrderDBConnection" connection string:

```bash
"Alpha:ConnectionStrings:OrderDBConnection"

"Bravo:ConnectionStrings:OrderDBConnection"

"Charlie:ConnectionStrings:OrderDBConnection"
```
