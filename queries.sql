--------------------------------------------------------------------------------------------------------------------
-- Cloud Tenants
--------------------------------------------------------------------------------------------------------------------

-- name: CreateCloudTenant :exec
insert into cloud_tenants (cloud, tenant_id, name)
values ($1, $2, $3)
on conflict (cloud, tenant_id) do update set name       = $3,
                                             updated_at = now();

-- name: GetCloudTenants :many
select *
from cloud_tenants
order by cloud, tenant_id;

-- name: GetCloudTenant :one
select *
from cloud_tenants
where cloud = $1
  and tenant_id = $2;

--------------------------------------------------------------------------------------------------------------------
-- Cloud Account Metadata
--------------------------------------------------------------------------------------------------------------------

-- name: CreateOrInsertCloudAccount :one
insert into cloud_accounts (cloud, tenant_id, account_id, name, tags_current, tags_desired)
VALUES ($1, $2, $3, $4, $5, $6)
ON CONFLICT (cloud, tenant_id, account_id)
    DO UPDATE SET name         = $4,
                  tags_current = $5,
                  updated_at   = now()
returning *;

-- name: UpdateCloudAccountTagsDriftDetected :exec
update cloud_accounts
set tags_drift_detected = $1,
    updated_at          = now()
where cloud = $2
  and tenant_id = $3
  and account_id = $4;

-- name: UpdateCloudAccount :exec
update cloud_accounts
set tags_desired = $4,
    updated_at   = now()
where cloud = $1
  and tenant_id = $2
  and account_id = $3;

-- name: GetCloudAllAccounts :many
select *
from cloud_accounts
order by cloud, tenant_id, account_id;

-- name: GetCloudAllAccountsForCloud :many
select *
from cloud_accounts
where cloud = $1
order by tenant_id, account_id;

-- name: GetCloudAllAccountsForCloudAndTenant :many
select *
from cloud_accounts
where cloud = $1
  and tenant_id = $2
order by account_id;

-- name: GetCloudAccount :one
select *
from cloud_accounts
where cloud = $1
  and tenant_id = $2
  and account_id = $3;