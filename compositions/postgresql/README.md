# PostgresDatabase Crossplane Composition

Provides a `PostgresDatabase` claim interface for application teams to self-service managed RDS PostgreSQL instances. The composition handles the underlying RDS instance, DBSubnetGroup, and connection secret.

## Claim Example

```yaml
apiVersion: platform.tcs.io/v1alpha1
kind: PostgresDatabase
metadata:
  name: my-app-db
  namespace: my-app
spec:
  parameters:
    storageGB: 20
    instanceClass: db.t3.medium
    multiAZ: false
    backupRetentionDays: 7
    engineVersion: "15.4"
    deletionPolicy: Orphan
  writeConnectionSecretToRef:
    name: my-app-db-conn
```

## Connection Secret

The composition writes a connection secret with the following keys:

| Key | Description |
|-----|-------------|
| `host` | RDS endpoint hostname |
| `port` | RDS port (usually `5432`) |
| `username` | Master username |
| `password` | Master password |
| `dbname` | Initial database name |
| `url` | Full `postgresql://user:pass@host:port/dbname` connection string |

The secret is written to the same namespace as the claim. Applications can mount it directly as environment variables or a volume.

## Automatic multiAZ in Production

The composition includes a namespace-label patch: if the claim's namespace has the label `platform.tcs.io/environment=production`, `multiAZ` is forced to `true` regardless of what the claim specifies. This prevents development teams from accidentally provisioning single-AZ databases in production environments.

Label your production namespaces:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: my-production-app
  labels:
    platform.tcs.io/environment: production
```

## Deletion Policy

The `deletionPolicy` parameter defaults to `Orphan`. When set to `Orphan`, deleting the `PostgresDatabase` claim removes the Crossplane-managed objects but leaves the underlying RDS instance running in AWS. This is the safe default for production databases.

**Do not change the default to `Delete` in production.** If you delete the claim, the RDS instance and all its data are permanently destroyed.

## Engine Version Upgrades

If you update `engineVersion` in the claim (e.g. from `14.9` to `15.4`), Crossplane will attempt to update the RDS instance in place. AWS supports in-place minor version upgrades, but major version upgrades require a snapshot, a new instance, and a manual data migration. To upgrade a major version safely:

1. Create a new `PostgresDatabase` claim with the new engine version.
2. Migrate your data to the new instance (pg_dump / pg_restore or DMS).
3. Cut over your application connection strings.
4. Delete the old claim (with `deletionPolicy: Orphan` to protect the data).
5. After confirming the new instance is healthy, manually delete the orphaned RDS instance.

Never set `engineVersion` to a major version jump and apply it directly to a production claim.

## Subnet Group Naming

DBSubnetGroup names are derived from the claim namespace and name (`tcs-<namespace>-<name>-subnet-group`). This prevents name collisions when multiple `PostgresDatabase` claims exist in the same namespace.
